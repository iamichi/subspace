#!/usr/bin/env bash
# Exercise scripts/sign-windows.sh with a fake az and jsign: configuration from
# the environment and Key Vault, the jsign call, archive rewriting and failures.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin" "$fixture/work/licenses"
export FIXTURE_STATE="$fixture/state" FAIL_AT=''
mkdir -p "$FIXTURE_STATE"

cat >"$fixture/bin/az" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
printf 'az %s\n' "$*" >>"$FIXTURE_STATE/az.log"
case "$1 $2" in
'keyvault secret')
	test "$3" = show && test "$4" = --vault-name && test "$5" = fixture-vault
	test "$6" = --name
	case "$7" in
	Subspace--WindowsSigningEndpoint) echo 'https://weu.codesigning.azure.net/' ;;
	Subspace--WindowsSigningAccount) echo fixture-account ;;
	Subspace--WindowsSigningCertificateProfile) [[ "$FAIL_AT" = profile ]] || echo fixture-profile ;;
	*) exit 92 ;;
	esac ;;
'account get-access-token')
	test "$3" = --resource && test "$4" = https://codesigning.azure.net
	echo fixture-token ;;
*) exit 93 ;;
esac
SH
cat >"$fixture/bin/jsign" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >"$FIXTURE_STATE/jsign.args"
test "$SUBSPACE_WINDOWS_SIGNING_TOKEN" = "${EXPECTED_TOKEN:-fixture-token}"
[[ "$FAIL_AT" != jsign ]] || { echo 'jsign fixture failure' >&2; exit 17; }
shift 13
for file in "$@"; do printf 'SIGNED' >>"$file"; done
SH
chmod +x "$fixture/bin/az" "$fixture/bin/jsign"
export PATH="$fixture/bin:$PATH"
unset SUBSPACE_WINDOWS_SIGNING_ENDPOINT SUBSPACE_WINDOWS_SIGNING_ACCOUNT \
	SUBSPACE_WINDOWS_SIGNING_PROFILE SUBSPACE_WINDOWS_SIGNING_TOKEN \
	SUBSPACE_SIGNING_KEY_VAULT SUBSPACE_JSIGN_JAR

sign() { bash "$root/scripts/sign-windows.sh" "$@"; }
expect_failure() {
	local message="$1"
	shift
	if "$@" >"$fixture/out" 2>&1; then
		echo "expected failure: $*" >&2
		exit 1
	fi
	grep -Fq -- "$message" "$fixture/out" || { cat "$fixture/out" >&2; exit 1; }
}
make_archive() {
	(
		cd "$fixture/work"
		printf 'exe' >subspace.exe
		printf 'readme' >README.md
		printf '{}' >product.json
		printf 'licence' >licenses/LICENSE
		rm -f "$1"
		zip -qrX "$1" subspace.exe README.md product.json licenses
	)
}

# Without configuration or a vault, it names what is missing.
printf 'exe' >"$fixture/app.exe"
expect_failure 'missing SUBSPACE_WINDOWS_SIGNING_ENDPOINT' sign "$fixture/app.exe"
printf 'x' >"$fixture/notes.txt"
expect_failure 'unsupported file type' sign "$fixture/notes.txt"
expect_failure 'no such file' sign "$fixture/missing.exe"

# Everything missing comes from Key Vault; the token never reaches the command line.
export SUBSPACE_SIGNING_KEY_VAULT=fixture-vault
sign "$fixture/app.exe" >/dev/null
test "$(cat "$fixture/app.exe")" = exeSIGNED
expected="--storetype TRUSTEDSIGNING --keystore weu.codesigning.azure.net --storepass env:SUBSPACE_WINDOWS_SIGNING_TOKEN --alias fixture-account/fixture-profile --tsaurl http://timestamp.acs.microsoft.com/ --tsmode RFC3161 --replace $fixture/app.exe"
test "$(cat "$FIXTURE_STATE/jsign.args")" = "$expected"
if grep -q fixture-token "$FIXTURE_STATE/jsign.args"; then echo 'the token reached the jsign command line' >&2; exit 1; fi
test "$(grep -c 'keyvault secret show' "$FIXTURE_STATE/az.log")" = 3

# The environment wins over Key Vault, and a given token skips az entirely.
: >"$FIXTURE_STATE/az.log"
printf 'exe' >"$fixture/app.exe"
SUBSPACE_WINDOWS_SIGNING_ENDPOINT=https://neu.codesigning.azure.net \
	SUBSPACE_WINDOWS_SIGNING_ACCOUNT=env-account SUBSPACE_WINDOWS_SIGNING_PROFILE=env-profile \
	SUBSPACE_WINDOWS_SIGNING_TOKEN=env-token EXPECTED_TOKEN=env-token sign "$fixture/app.exe" >/dev/null
test ! -s "$FIXTURE_STATE/az.log"
grep -Fq -- '--keystore neu.codesigning.azure.net' "$FIXTURE_STATE/jsign.args"
grep -Fq -- '--alias env-account/env-profile' "$FIXTURE_STATE/jsign.args"

# A wrong endpoint never receives the token.
rm -f "$FIXTURE_STATE/jsign.args"
expect_failure 'not an Artifact Signing endpoint' env SUBSPACE_WINDOWS_SIGNING_ENDPOINT=https://example.com/ \
	bash "$root/scripts/sign-windows.sh" "$fixture/app.exe"
test ! -e "$FIXTURE_STATE/jsign.args"
FAIL_AT=profile expect_failure 'could not read Subspace--WindowsSigningCertificateProfile' sign "$fixture/app.exe"

# A release archive keeps its entries and order, with the signed exe and a fresh checksum.
archive="$fixture/work/subspace-1.2.3-x86_64-pc-windows-msvc.zip"
make_archive "$archive"
before="$(unzip -Z1 "$archive")"
sign "$archive" "$fixture/app.exe" >/dev/null
test "$(unzip -Z1 "$archive")" = "$before"
test "$(unzip -p "$archive" subspace.exe)" = exeSIGNED
test "$(unzip -p "$archive" README.md)" = readme
grep -Fq -- "--replace " "$FIXTURE_STATE/jsign.args"
grep -Fq -- "/subspace.exe $fixture/app.exe" "$FIXTURE_STATE/jsign.args"
(cd "$fixture/work" && if command -v sha256sum >/dev/null; then sha256sum -c "$(basename "$archive").sha256"; else shasum -a 256 -c "$(basename "$archive").sha256"; fi) >/dev/null

# A jsign failure leaves the archive untouched.
make_archive "$archive"
original="$(cksum <"$archive")"
FAIL_AT=jsign expect_failure 'jsign fixture failure' sign "$archive"
test "$(cksum <"$archive")" = "$original"

# An archive without a Windows executable is refused.
(cd "$fixture/work" && rm -f empty.zip && zip -qX empty.zip README.md)
expect_failure 'no .exe or .dll to sign' sign "$fixture/work/empty.zip"

echo 'sign-windows fixtures passed'
