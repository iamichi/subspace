#!/usr/bin/env bash
# Sign Windows files with Azure Artifact Signing through jsign, on any OS.
# Usage: scripts/sign-windows.sh FILE...
#
# A .exe, .dll, .msi or .msix file is signed in place. A .zip release archive
# has every .exe and .dll entry signed, is rewritten with the same entries in
# the same order, and gets a fresh .sha256 file beside it. All files go to one
# jsign call, which saves Artifact Signing quota.
#
# The signing account comes from the environment, and anything missing from
# the Key Vault named by SUBSPACE_SIGNING_KEY_VAULT (see
# docs/installation.md#sign-windows-releases). The caller must be signed in
# with az and hold Artifact Signing Certificate Profile Signer, unless
# SUBSPACE_WINDOWS_SIGNING_TOKEN already holds an access token.
set -euo pipefail
# Never trace the access token, even if the caller enabled shell tracing.
set +x

if [[ "$#" -eq 0 ]]; then
	echo 'usage: sign-windows.sh FILE... (.exe, .dll, .msi, .msix or a release .zip)' >&2
	exit 2
fi

fail() {
	echo "$*" >&2
	exit 1
}

for path in "$@"; do
	[[ -f "$path" ]] || fail "no such file: $path"
	case "$path" in
	*.exe | *.dll | *.msi | *.msix | *.zip) ;;
	*) echo "unsupported file type, expected .exe, .dll, .msi, .msix or .zip: $path" >&2; exit 2 ;;
	esac
done

vault="${SUBSPACE_SIGNING_KEY_VAULT:-}"
for entry in SUBSPACE_WINDOWS_SIGNING_ENDPOINT:Subspace--WindowsSigningEndpoint \
	SUBSPACE_WINDOWS_SIGNING_ACCOUNT:Subspace--WindowsSigningAccount \
	SUBSPACE_WINDOWS_SIGNING_PROFILE:Subspace--WindowsSigningCertificateProfile; do
	name="${entry%%:*}"
	secret="${entry#*:}"
	if [[ -n "${!name:-}" ]]; then
		continue
	fi
	if [[ -z "$vault" ]]; then
		fail "missing $name: set it, or set SUBSPACE_SIGNING_KEY_VAULT to read $secret from Key Vault"
	fi
	command -v az >/dev/null || fail "missing $name, and the Azure CLI (az) is not installed to read $secret from Key Vault"
	if ! value="$(az keyvault secret show --vault-name "$vault" --name "$secret" \
		--query value --output tsv)" || [[ -z "$value" ]]; then
		fail "could not read $secret from Key Vault for $name. Run az login, and check that you have Key Vault Secrets User on the secret"
	fi
	printf -v "$name" '%s' "$value"
done
unset value

# jsign wants the endpoint's host. Refuse anything but an Artifact Signing
# endpoint, so a wrong value never receives the access token.
endpoint="${SUBSPACE_WINDOWS_SIGNING_ENDPOINT#https://}"
endpoint="${endpoint%/}"
[[ "$endpoint" =~ ^[a-z0-9]+\.codesigning\.azure\.net$ ]] ||
	fail "SUBSPACE_WINDOWS_SIGNING_ENDPOINT is not an Artifact Signing endpoint such as https://weu.codesigning.azure.net/"
account="$SUBSPACE_WINDOWS_SIGNING_ACCOUNT"
profile="$SUBSPACE_WINDOWS_SIGNING_PROFILE"
[[ "$account" =~ ^[A-Za-z][A-Za-z0-9-]{2,23}$ ]] || fail 'SUBSPACE_WINDOWS_SIGNING_ACCOUNT is not a signing account name'
[[ "$profile" =~ ^[A-Za-z0-9][A-Za-z0-9-]{0,99}$ ]] || fail 'SUBSPACE_WINDOWS_SIGNING_PROFILE is not a certificate profile name'

if [[ -n "${SUBSPACE_JSIGN_JAR:-}" ]]; then
	command -v java >/dev/null || fail 'SUBSPACE_JSIGN_JAR is set, but java is not installed'
	[[ -f "$SUBSPACE_JSIGN_JAR" ]] || fail "SUBSPACE_JSIGN_JAR does not exist: $SUBSPACE_JSIGN_JAR"
	jsign=(java -jar "$SUBSPACE_JSIGN_JAR")
elif command -v jsign >/dev/null; then
	jsign=(jsign)
else
	fail 'jsign is not installed: brew install jsign, or set SUBSPACE_JSIGN_JAR to the jsign JAR (https://github.com/ebourg/jsign/releases)'
fi

if [[ -z "${SUBSPACE_WINDOWS_SIGNING_TOKEN:-}" ]]; then
	command -v az >/dev/null || fail 'the Azure CLI (az) is required for an Artifact Signing access token'
	SUBSPACE_WINDOWS_SIGNING_TOKEN="$(az account get-access-token \
		--resource https://codesigning.azure.net --query accessToken --output tsv)" ||
		fail 'could not get an Artifact Signing access token. Run az login to the signing tenant'
	[[ -n "$SUBSPACE_WINDOWS_SIGNING_TOKEN" ]] || fail 'az returned an empty Artifact Signing access token'
fi
# jsign reads the token from its environment, never from its command line.
export SUBSPACE_WINDOWS_SIGNING_TOKEN

checksum() {
	if command -v sha256sum >/dev/null; then sha256sum "$1"; else shasum -a 256 "$1"; fi
}

# mktemp -d makes the stage private (0700) to this user.
stage="$(mktemp -d "${RUNNER_TEMP:-${TMPDIR:-/tmp}}/subspace-windows-signing.XXXXXX")"
trap 'rm -rf "$stage"' EXIT

files=()
archives=()
for path in "$@"; do
	case "$path" in
	*.zip)
		if ! command -v unzip >/dev/null || ! command -v zip >/dev/null; then fail 'signing a .zip needs zip and unzip'; fi
		index="${#archives[@]}"
		archives+=("$path")
		mkdir "$stage/$index"
		unzip -Z1 "$path" >"$stage/$index.entries"
		unzip -q "$path" -d "$stage/$index/tree"
		found=0
		while IFS= read -r member; do
			case "$member" in
			*.exe | *.dll | *.EXE | *.DLL) files+=("$stage/$index/tree/$member"); found=1 ;;
			esac
		done <"$stage/$index.entries"
		[[ "$found" = 1 ]] || fail "no .exe or .dll to sign in $path"
		;;
	*) files+=("$path") ;;
	esac
done

"${jsign[@]}" --storetype TRUSTEDSIGNING --keystore "$endpoint" \
	--storepass env:SUBSPACE_WINDOWS_SIGNING_TOKEN --alias "$account/$profile" \
	--tsaurl http://timestamp.acs.microsoft.com/ --tsmode RFC3161 \
	--replace "${files[@]}"

for index in "${!archives[@]}"; do
	archive="${archives[$index]}"
	directory="$(cd "$(dirname "$archive")" && pwd)"
	base="$(basename "$archive")"
	rebuilt="$stage/$index.zip"
	# The same entries in the same order: the updater selects subspace.exe by
	# its exact name at the archive root.
	(cd "$stage/$index/tree" && zip -qX "$rebuilt" -@ <"$stage/$index.entries")
	unzip -Z1 "$rebuilt" | cmp -s - "$stage/$index.entries" || fail "the signed archive's entries differ from $archive"
	mv -f "$rebuilt" "$directory/$base"
	(cd "$directory" && checksum "$base" >"$base.sha256")
	echo "signed $archive"
done
for path in "$@"; do
	case "$path" in *.zip) ;; *) echo "signed $path" ;; esac
done
