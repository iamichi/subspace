# Install Subspace

## Quick start

[!INCLUDE [Download and open an app](subspace/includes/quick-start.md)]

## Other ways to install

The Subspace App (`subspace`) is a binary built from the Subspace Framework.
See [the glossary](glossary.md). The sections below cover source builds,
packaging, release installer scripts and pre-release channels. For a first
desktop installation, use the download-and-copy steps above.

Subspace is maintained under `subspace-desktop` in
[`aiconsultancy/subspace`](https://github.com/aiconsultancy/subspace).
The Subspace App and the Subspace Framework use `subspace-desktop-vX.Y.Z`. Do
not use the repository-wide Latest release. Use the Subspace stable release
page above.

Application, dependency, mixed and unrecognized changes get full PR CI on
Linux, macOS and Windows. Narrow workflow-only changes run workflow contracts
instead. Same-repository Release Please bot PRs can also use this fast lane
when JSON/TOML comparison proves that only documented version fields, owned
local lockfile versions and changelogs changed. External dependency changes
cannot use it. The required PR gate still waits for the selected checks and
fails if any of them fail.

Release Please owns version changes, release pull requests and tags. Its PR creation
does not wait for post-merge cache warming. Only the release PR merge starts
the three target builds; an existing draft alone does not.
Release merges rely on the required PR gate instead of repeating main-branch
host checks and cache builds. Mac signing runs alongside platform packaging.
Each release stays a draft until its three plain
archives and signed macOS app pass validation and upload. A missing signing
secret, rejected notarization, or other app failure prevents publication.

Pre-releases (nightly, alpha and beta) are a separate workflow. Release
Please does not own them, and they do not change stable versions, tags or
changelogs. See [Pre-releases](#pre-releases).

## Build from source

Install [mise](https://mise.jdx.dev). It pins Rust 1.99.0 with the Mr Boxington
build cache.

```bash
make build      # debug build of every crate
make run        # start the desktop app
make check      # format check, clippy and tests
make interfaces # real headless product interface
make run ARGS='--help' # headless CLI help
```

On Linux, GPUI needs these packages (Ubuntu names): `gcc g++ clang
libfontconfig-dev libwayland-dev libxkbcommon-x11-dev libx11-xcb-dev
libssl-dev libzstd-dev libvulkan-dev`.

## Release targets

A release has one archive for each of these Rust targets:

| Rust target | Archive |
| --- | --- |
| `x86_64-unknown-linux-gnu` | `subspace-<version>-x86_64-unknown-linux-gnu.tar.gz` |
| `aarch64-apple-darwin` | `subspace-<version>-aarch64-apple-darwin.tar.gz` |
| `x86_64-pc-windows-msvc` | `subspace-<version>-x86_64-pc-windows-msvc.zip` |

`x86_64-apple-darwin` (Intel Mac) and `aarch64-pc-windows-msvc` (Windows
arm64) receive no new native builds. The release installers fail with a clear
message on those platforms. New releases support only the three targets listed
above.

macOS builds need macOS 15 or later. `scripts/product.sh` sets the minimum
version once in `MACOS_MINIMUM_VERSION`.

Each archive has a checksum file with the same name and a `.sha256` suffix.
The archive holds the selected binary, `README.md` and validated `product.json`
at its root. Windows ZIP archives contain `subspace.exe`; the updater selects
that exact entry, including the `.exe` extension. In a published release,
`subspace.exe` is Authenticode-signed with Azure Artifact Signing (see
[Sign Windows releases](#sign-windows-releases)).

Linux ARM64 receives no new CI builds or release archives. For that platform,
select an older release that includes its archive with the installer's
`--version` option. Historical installer support remains unchanged.

Each release also has one signed Apple silicon app archive,
`Subspace_<version>_darwin_arm64.zip`, containing `Subspace.app`.

The plain `aarch64-apple-darwin.tar.gz` archive remains available for CLI use.

## Package a release

```bash
make package                                          # this machine
make package TARGET=x86_64-unknown-linux-gnu          # one target
make package TARGET=aarch64-apple-darwin VERSION=0.1.0
```

`mise run package -- [RUST_TARGET [VERSION]]` does the same. The script
`scripts/package-release.sh` builds with `--release --locked`, then writes the
archive and its `.sha256` file to `dist/`. The version comes from Cargo
metadata: the Subspace App inherits `[workspace.package].version`. If you pass
`VERSION`, the script stops when it differs from that version.

When the host can run the target, the packager also executes the binary's
headless `__product_metadata` route before replacing an archive. The machine
version remains plain semver. An incompatible cross-target reports that this
check was skipped.

Scripts read names, bundle IDs, icons, themes and version through the headless
`subspace-product-metadata` utility. It does not initialize GPUI to obtain
packaging metadata.

The script builds natively for the target. A target other than the host needs
its Rust target installed (the script runs `rustup target add`) and a linker
and system libraries for that target. Each release target is best built on a
runner of its own platform.

Verify a package:

```bash
cd dist
sha256sum -c subspace-0.1.0-x86_64-unknown-linux-gnu.tar.gz.sha256
tar -tzf subspace-0.1.0-x86_64-unknown-linux-gnu.tar.gz
```

## Build a signed macOS application

For a local installation without Developer ID signing or notarization, run:

```bash
make install-macos
```

This command builds Subspace, signs it ad hoc, verifies the signature, and
replaces its bundle in `~/Applications`. Quit Subspace first. The installer
refuses to replace a running app. The Make command enables the `terminal`
Cargo feature and select the Terminal mise environment for Zig.
Set `FEATURES` to override the feature list, or `FEATURES=` to omit Terminal.
Set `TARGET` to choose a macOS architecture. For the equivalent direct mise
call, use `MISE_ENV=terminal SUBSPACE_BUILD_FEATURES=terminal mise run install-macos -- [RUST_TARGET]`.

The local installer and the signed packaging task below share
`scripts/build-macos-app.sh` and the validated product metadata. The local
installer does not download or publish a release.

Run this task on a Mac with Xcode command-line tools and a Developer ID
Application certificate with its private key in Keychain. Store notarization
credentials in Keychain first. This command prompts for the Apple ID, team ID,
and app-specific password:

```bash
xcrun notarytool store-credentials subspace-notary
```

Do not put passwords or private keys in the repository. You can also use an
existing notarization Keychain profile from another app.

Store the client secret of Subspace's GitHub OAuth App in the login Keychain
too, so the app's **Sign in with GitHub** can use the browser. This command
prompts for the secret, which comes from the OAuth App's page on GitHub:

```bash
security add-generic-password -s subspace-github-oauth -a client-secret -w
```

Packaging reads it when `SUBSPACE_GITHUB_OAUTH_CLIENT_SECRET` is unset, passes
it only to the Cargo build, which compiles it into the app, and checks that
the built executable contains it. The secret is never printed and never in
the repository. Without it, `make package-macos` warns and builds an app that
signs in to GitHub with a code instead; a stable release refuses to start.
GitHub Desktop and the GitHub CLI ship their OAuth secrets the same way: an
installed app cannot keep a secret from its user, so the OAuth App relies on
PKCE and its registered loopback callback rather than on the secret.

#### Build configuration

The Framework names no OAuth App and no issue repository; the app passes
both to it. Their defaults are in `products/subspace/build/config.rs`, and
the product's build script reads three variables from the build
environment, re-running when any of them changes:

| Variable | Default | Effect |
| --- | --- | --- |
| `SUBSPACE_GITHUB_OAUTH_CLIENT_ID` | Subspace's OAuth App | The OAuth App that **Sign in with GitHub** uses. Empty builds an app without Sign in with GitHub; accounts then come from the environment, the config file and `gh`. |
| `SUBSPACE_GITHUB_OAUTH_CLIENT_SECRET` | None | That OAuth App's client secret, as above. Compiled in, never printed and never in the build script's output. |
| `SUBSPACE_REPORT_ISSUE_REPOSITORY` | `aiconsultancy/subspace` | The repository **Report issue** files into (`owner/name`). Empty builds an app without Report issue. |

The product's `report-issue` Cargo feature, on by default, compiles Report
issue in; `--no-default-features` leaves it out entirely.

Signing and notarization need the desktop login session: a shell reached
over SSH, including an agent server started that way, cannot use the login
Keychain (`codesign` fails with `errSecInternalComponent` and `notarytool`
reports no Keychain password item). `launchctl managername` prints `Aqua` in
that session. `make package-macos` and `make release-macos` move into it by
themselves, with no window, when started anywhere else; see
[Publish a macOS release](#publish-a-macos-release). The Mac must be logged
in at its desktop.

```bash
make package-macos
```

`SIGNING_IDENTITY` defaults to the team's Developer ID Application identity,
`Developer ID Application: Thoughtsun Limited (576985M4ZN)`, and
`KEYCHAIN_PROFILE` defaults to `subspace-notary`. Pass either on the command
line to use another, for example
`make package-macos SIGNING_IDENTITY='Developer ID Application: <your team> (<team ID>)'`.

`mise run package-macos -- SIGNING_IDENTITY KEYCHAIN_PROFILE [RUST_TARGET]`
does the same. `aarch64-apple-darwin` is the only supported macOS target; the
default is this Mac's architecture.

The task builds the release binary, creates `Subspace.app`, signs it with
hardened runtime and a secure timestamp, and submits it to Apple. It staples
the notarization ticket and verifies the signature, ticket, and Gatekeeper
acceptance before writing:

- `dist/Subspace.app`
- `dist/Subspace_<version>_darwin_arm64.zip`, containing the stapled app

Run `bash scripts/test-package-products.sh` to check packaging in isolated
fixtures without real signing or notarization.

### Publish a macOS release

A stable release starts as a draft. Merging the app's Release Please pull
request (see [Releases](ways-of-working.md#releases)) makes the release
workflow tag the merge commit `subspace-desktop-v<version>` and create a
draft GitHub release with the changelog's entry as its notes. Then, on the
owner's Mac:

```bash
git fetch --tags origin
git switch --detach subspace-desktop-v<version>
make release-macos
```

This runs `make package-macos`, writes the archive's `.sha256` file,
attaches both to the draft and publishes it, titled `Subspace <version>`.
The version is the workspace version in `Cargo.toml`. Before it builds
anything, it checks that `gh` is signed in, that the project has no local
changes, that the commit is on GitHub, that the release exists and is still a
draft, that its tag is the commit checked out, and, for a stable release,
that the GitHub OAuth client secret is in the login Keychain (see above) or
in `SUBSPACE_GITHUB_OAUTH_CLIENT_SECRET`. It never changes a published
release.

- `DRAFT=1` attaches the files but leaves the release a draft; run it again
  without `DRAFT=1` to publish it (it replaces the draft's files).
- `RELEASE_NOTES_FILE=<file>` replaces the changelog's notes with yours.
- `RELEASE_REPO=OWNER/REPO` publishes to another repository; the default is
  `aiconsultancy/subspace`.
- A pre-release channel build or a pre-release version is not a Release
  Please release: the script creates it as a new pre-release, as for
  [integration builds](#integration-builds).

Signing needs the macOS desktop login session, where the Developer ID key in
the login keychain is usable; elsewhere, such as over SSH or from an agent's
shell (`launchctl managername` prints something other than `Aqua`),
`codesign` fails with `errSecInternalComponent`. So `make release-macos` and
`make package-macos` run themselves in that session when started outside it,
through `scripts/desktop-session.sh`: a one-off launchd agent in
`gui/<uid>`, with no window, that runs the command in the same folder,
streams its output back, returns its exit status and is removed afterwards,
also on Ctrl-C. The agent gets `PATH`, `HOME` and a named set of variables
(the signing, release, `MISE_*`, `SUBSPACE_*`, `CARGO_*` and `RUSTUP_*`
ones), never one whose name looks like a credential; the OAuth secret is read
from the login keychain inside the session, so a value in
`SUBSPACE_GITHUB_OAUTH_CLIENT_SECRET` does not cross. The Mac must be logged
in at its desktop.

`scripts/install-release.sh` installs the published app on another Mac.
`bash scripts/test-release-macos.sh` checks the release flow with a fake
`gh` and packager, and `bash scripts/test-desktop-session.sh` the session
helper with a fake `launchctl`.

#### packslip

Publishing a stable release (`make release-macos` turning the draft into a
published release) starts the `packslip` GitHub workflow (`.github/workflows/packslip.yml`). It signs a
[packslip](https://packslip.dev) for the release, a signed manifest of its
files, their SHA-256 digests, the platform (`darwin`, `aarch64`) and the
`subspace` command inside `Subspace.app`, and attaches it to the release as
`packslip.subspace-desktop.sigstore.json`. The project name is
`github.com/aiconsultancy/subspace/subspace-desktop`. It signs keylessly
with the workflow's GitHub identity, so there is no key to keep; Sigstore
records each signature, with the repository and workflow names, in its
public transparency log. To sign an older release, run the workflow by hand
with its tag:

```bash
gh workflow run packslip.yml -R aiconsultancy/subspace -f tag=subspace-desktop-v0.8.0
```

Sign every release from this one workflow file; consumers refuse a release
signed by another until a person approves it. Build provenance is not
linked, because GitHub attestations need Enterprise Cloud in a private
repository.

To check a download against its packslip (a GitHub token with access to
the repository is needed while it is private):

```bash
gh release download subspace-desktop-v<version> -R aiconsultancy/subspace
GITHUB_TOKEN="$(gh auth token)" packslip verify packslip.subspace-desktop.sigstore.json \
  --pin ps1_n7ptlnytm5dm6y5s2safxx3lbu \
  --artifact Subspace_<version>_darwin_arm64.zip
```

`ps1_n7ptlnytm5dm6y5s2safxx3lbu` is the signer fingerprint of
`aiconsultancy/subspace`; `--pin` accepts only releases signed in that
repository. 0.8.0 was the first release signed (by hand, from `main`); later
releases are signed from their tag.

A failed build or notarization leaves the previous output unchanged. Copy
the app to `~/Applications` or `/Applications`, then open it from Finder.
The bundle supplies standard Homebrew and system executable paths so that
service clients can find CLI tools without a terminal's shell configuration.
To update, replace the whole signed bundle, not its executable.

### Integration builds

Integration pre-releases are download-only snapshots of a branch, currently
`feat/subspace-desktop`. On a Mac with the signing and notarization setup
above, sign in with `gh auth login`, push the commit to GitHub, then run from
the clean integration checkout:

```bash
make release-macos-prerelease
```

The command accepts the same `SIGNING_IDENTITY`, `KEYCHAIN_PROFILE`, `DRAFT=1`,
`RELEASE_REPO` and `RELEASE_NOTES_FILE` overrides as `release-macos`. It refuses
a detached HEAD, any tracked or untracked change in the repository, reserved
branch slugs (`stable`, `nightly`, `alpha`, `beta`), an unpublished commit or
an existing release. The newest published stable tag must be available locally
(fetch tags first if the planner reports it missing). It refuses a build with
no app-changing commits since that tag. It temporarily stamps the workspace
and lockfile, builds, signs, notarizes and staples through the existing macOS
packaging path, then
restores the original version files even on failure. No version commit is
needed.

The version is `<base>-<branch-slug>.<id>.g<sha7>`:

- `<base>` is the next release under the [versioning rule](ways-of-working.md#versioning),
  starting from the newest published stable Subspace release. The planner
  counts conventional commit subjects since that tag, restricted to
  `subspace-desktop`, and checks bodies for `BREAKING CHANGE` footers. Any
  `feat`, or any breaking change below 1.0, bumps the minor version; breaking
  changes from 1.0 bump the major version. `fix`/`perf` alone bump the patch.
  The highest applicable bump wins. Today's features since `0.2.1` give
  `0.3.0`. Drafts and other products are ignored. Nightly, alpha and beta
  continue to use the existing stable-plus-one-patch base.
- `<branch-slug>` lowercases the branch name and replaces `/` and every
  character outside `[0-9a-z-]` with `-`.
- `<id>` is the HEAD commit's committer timestamp as UTC `YYYYMMDDHHMM`.
- `<sha7>` is the first seven characters of HEAD's full SHA.

For example, it publishes
`subspace-desktop-v0.3.0-feat-subspace-desktop.202611151345.gabc1234`, marked
**pre-release** and **never Latest**, with
`Subspace_0.3.0-feat-subspace-desktop.202611151345.gabc1234_darwin_arm64.zip`
and its `.sha256`. Rebuilding the same commit with the same stable base gets
the same version; a second publication refuses the existing release.

Install an integration build on another Mac by pinning its full version:

```bash
sh scripts/install-release.sh --version 0.3.0-feat-subspace-desktop.202611151345.gabc1234
```

Use the shell installer for integration versions. `install-release.ps1`
does not accept integration versions; it accepts only stable or its selected
nightly, alpha or beta channel.

There is no integration update channel. The app retains stable's `Subspace`
name, bundle id, icons and data locations, so this replaces the installed
stable app. On macOS, an explicit integration install replaces
`~/Applications/Subspace.app` and replaces the stable CLI symlink with a link
to that app (by default `~/.local/bin/subspace`; `--bin-dir` selects another
link directory). Check the version in the status bar to identify the build. An
integration build shows no update controls, has no updater and never checks
for, offers or installs an update, including stable `0.2.1`. Stable, nightly,
alpha and beta builds never
offer integration releases. Install a newer integration build explicitly; to
return to stable, rerun `sh scripts/install-release.sh` without `--version`.
Returning to stable is a downgrade over the same data locations.

Offline fixtures cover the release planner, stamp and Mac release orchestration
on Linux too: `python3 scripts/test-prereleases.py`. No fixture publishes a
release or calls GitHub's API.

The signed packaging task does not publish or install the app. The release job
runs the same packager with credentials from the protected environment
described below.

### Configure release signing in GitHub

An administrator must configure these settings before a release can publish:

1. Export your Developer ID Application certificate and private key from Keychain Access as a password-protected
   `.p12` file.
2. Create an App Store Connect API key that can submit software for
   notarization. Download its `.p8` file once and record its key ID and issuer
   ID.
3. In the repository, create the GitHub environment
   `subspace-macos-signing`. Add a deployment branch rule that permits only
   `main`. Add required reviewers if release approval must be manual.
4. Add these environment secrets. Do not add them as repository secrets:

   | Secret | Value |
   | --- | --- |
   | `MACOS_CERTIFICATE_BASE64` | Base64 text of the `.p12` file, for example `base64 < certificate.p12 \| pbcopy` |
   | `MACOS_CERTIFICATE_PASSWORD` | Password used when exporting the `.p12` file |
   | `MACOS_SIGNING_IDENTITY` | Your Developer ID Application identity, for example `Developer ID Application: <your team> (<team ID>)` |
   | `APPLE_API_KEY_BASE64` | Base64 text of the App Store Connect `.p8` file, for example `base64 < AuthKey_ID.p8 \| pbcopy` |
   | `APPLE_API_KEY_ID` | App Store Connect API key ID |
   | `APPLE_API_ISSUER_ID` | App Store Connect API issuer ID |

The caller in `subspace-release.yml` must explicitly pass all six secret names
to the reusable product workflow. Its `workflow_call.secrets` declarations
make that contract required. GitHub resolves the values from the signing
job's environment; do not copy them to repository secrets or use broad
`secrets: inherit`. Declaring `environment:` alone leaves these secrets empty
in a reusable workflow. See [GitHub's reusable workflow secret guidance](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows#using-inputs-and-secrets-in-a-reusable-workflow).

The release runner imports the certificate into a temporary Keychain, stores a
temporary `notarytool` profile, unsets the secret environment variables before
compilation, and deletes the Keychain on success or failure. Pull request CI
does not request this environment and cannot read these secrets.

The temporary Keychain must also be in the runner user's search list.
`codesign --keychain` restricts lookup but does not register a Keychain. The
wrapper adds it without dropping existing entries, then restores the original
search list during cleanup before deleting the temporary Keychain. It does
not change the default Keychain, trust settings or other secret values.

Before compiling the app, the wrapper checks for a valid Developer ID
Application identity in that Keychain and runs `codesign --dryrun` with the
configured selector on a private copy of a system executable. The dry run
checks identity selection and private-key access but discards its signature.
A failure stops before compilation or notarization credential setup. The
wrapper's added diagnostic lists only public certificate SHA-1 fingerprints,
not certificate names, passwords, private keys or Apple API keys. The signing
job disables Rustqual installation; it is not needed to build or sign the app.

Signing and publication run only on the push to `main` that merges the
Release Please PR. The workflow checks the merged PR's commit,
repository, bot author, component branch and release label. An ordinary merge,
a manual workflow run or an existing draft alone cannot start signing. Retry
a signing failure by rerunning the original release-merge run or its failed
jobs, rather than dispatching a new workflow.

### Sign from an Azure Key Vault

`make package-macos-ci TARGET=aarch64-apple-darwin VERSION=<x.y.z>` reads any
of the six secrets missing from the environment from the Azure Key Vault named
by `SUBSPACE_SIGNING_KEY_VAULT`, for example
`SUBSPACE_SIGNING_KEY_VAULT=your-signing-vault`. There is no default vault: if
a secret is missing and the variable is unset, the script stops before it
creates a keychain. Sign in with `az login` to the vault's tenant first. Each
signer needs **Key Vault Secrets User** on each of these secrets, not on the
whole vault:

| Environment variable | Key Vault secret |
| --- | --- |
| `MACOS_CERTIFICATE_BASE64` | `Subspace--MacosCertificateBase64` |
| `MACOS_CERTIFICATE_PASSWORD` | `Subspace--MacosCertificatePassword` |
| `MACOS_SIGNING_IDENTITY` | `Subspace--MacosSigningIdentity` |
| `APPLE_API_KEY_BASE64` | `Subspace--AppleApiKeyBase64` |
| `APPLE_API_KEY_ID` | `Subspace--AppleApiKeyId` |
| `APPLE_API_ISSUER_ID` | `Subspace--AppleApiIssuerId` |

A secrets officer writes each value from a file, so it never appears in a
command line or shell history, for example
`az keyvault secret set --vault-name your-signing-vault --name Subspace--MacosCertificateBase64 --file certificate.p12.b64 --output none`.
Set `MACOS_SIGNING_IDENTITY` to the certificate's SHA-1 fingerprint or its
full `Developer ID Application: <team> (<team ID>)` name.

### Sign Windows releases

`subspace.exe` is signed with [Azure Artifact Signing](https://learn.microsoft.com/azure/artifact-signing/)
(formerly Trusted Signing). There is no certificate file: Microsoft keeps the
key in its HSMs, issues a short-lived certificate for the account's
certificate profile and signs a digest that the client sends. The client is
[jsign](https://github.com/ebourg/jsign), which runs on macOS, Linux and
Windows, so signing needs no Windows machine and no network path other than
HTTPS to the Artifact Signing endpoint.

`make sign-windows FILES="<file> ..."` (`scripts/sign-windows.sh`) signs a
`.exe`, `.dll`, `.msi` or `.msix` in place. Given a release `.zip`, it signs
every `.exe` and `.dll` inside, rewrites the archive with the same entries in
the same order, and writes a fresh `.sha256` file beside it. Each file is
timestamped by Microsoft's RFC 3161 service, so its signature outlives the
certificate. The account comes from the environment, and anything missing
from the Key Vault named by `SUBSPACE_SIGNING_KEY_VAULT`:

| Environment variable | Key Vault secret |
| --- | --- |
| `SUBSPACE_WINDOWS_SIGNING_ENDPOINT` | `Subspace--WindowsSigningEndpoint`, the account's regional endpoint, such as `https://weu.codesigning.azure.net/` |
| `SUBSPACE_WINDOWS_SIGNING_ACCOUNT` | `Subspace--WindowsSigningAccount` |
| `SUBSPACE_WINDOWS_SIGNING_PROFILE` | `Subspace--WindowsSigningCertificateProfile` |

The script refuses an endpoint that is not `*.codesigning.azure.net`, so a
wrong value never receives the token. It asks `az` for an access token for
`https://codesigning.azure.net` (or uses `SUBSPACE_WINDOWS_SIGNING_TOKEN`) and
hands it to jsign through the environment, never on the command line. The
signer needs **Artifact Signing Certificate Profile Signer** on the account
or profile, and **Key Vault Secrets User** on each of the three secrets. To
sign from a Mac:

```bash
brew install jsign
az login --tenant <signing tenant>
SUBSPACE_SIGNING_KEY_VAULT=<vault> make sign-windows FILES=dist/subspace-0.10.0-x86_64-pc-windows-msvc.zip
```

Set `SUBSPACE_JSIGN_JAR` to a downloaded jsign JAR to run it with `java`
instead. `bash scripts/test-sign-windows.sh` checks the script with a fake
`az` and jsign.

#### The windows-release workflow

When the release workflow creates an app release, it starts
`.github/workflows/windows-release.yml` on `main` with the new tag. Every job
runs on the Subspace self-hosted ARC scale sets in the platform's Kubernetes
cluster (runner group `subspace-release`), never on GitHub-hosted runners:

1. **build**, on `subspace-windows`, checks out the tag and runs
   `scripts/package-release.sh x86_64-pc-windows-msvc <version>` with no
   secrets. The runner is a Windows Server 2022 container on a node pool that
   scales from zero to one, so a run may wait a few minutes for the node. A
   GPUI release build for Windows must run on Windows, because the renderer
   compiles its shaders with the Windows SDK's `fxc.exe` in a build script.
2. **sign**, on `subspace-signing`, a Linux runner in the trusted deployment
   subnet, runs in the `windows-signing` environment. It signs in to Azure
   with GitHub OIDC as the signing identity, installs Temurin and the pinned
   jsign JAR (checked against its SHA-256 digest) and runs `make sign-windows`
   on the archive. It reads the three secrets above through the platform Key
   Vault's private endpoint.
3. **publish**, back on `subspace-windows`, checks the archive's `.sha256` and
   that Windows reports the signature `Valid` with a timestamp, then attaches
   the archive and its `.sha256` file to the release. This is normally still
   the draft, before `make release-macos` publishes it.

The build job never holds the OIDC permission, so build scripts cannot request
a token for the signing identity. The runner group admits only this workflow
on `main`. To build an older release, or to try the build or the signing
without attaching anything:

```bash
gh workflow run windows-release.yml -R aiconsultancy/subspace --ref main -f tag=subspace-desktop-v0.10.0
gh workflow run windows-release.yml -R aiconsultancy/subspace --ref main -f tag=subspace-desktop-v0.10.0 -f mode=sign-only
gh workflow run windows-release.yml -R aiconsultancy/subspace --ref main -f tag=subspace-desktop-v0.10.0 -f mode=build-only
```

The `windows-signing` environment's deployment rule admits only `main` and
`subspace-desktop-v*` tags, and holds these environment secrets, so neither
the identity nor the vault is written in the repository:

| Secret | Value |
| --- | --- |
| `AZURE_SIGNING_CLIENT_ID` | Client ID of the signing managed identity |
| `AZURE_SIGNING_TENANT_ID` | Its tenant |
| `AZURE_SIGNING_SUBSCRIPTION_ID` | The subscription that holds the signing account |
| `SUBSPACE_SIGNING_KEY_VAULT` | The Key Vault holding the three secrets above |

The managed identity trusts one federated credential: issuer
`https://token.actions.githubusercontent.com`, audience
`api://AzureADTokenExchange`, subject
`repo:aiconsultancy@<owner id>/subspace@<repository id>:environment:windows-signing`.
This repository uses GitHub's immutable OIDC subjects (owner and repository
IDs), which
`gh api repos/aiconsultancy/subspace/actions/oidc/customization/sub` shows.

#### Set up Artifact Signing

An Azure administrator does this once:

1. Register the `Microsoft.CodeSigning` resource provider and create an
   Artifact Signing account (Basic SKU) in a supported region; its endpoint
   is shown on the account.
2. Give whoever validates the organisation's identity **Artifact Signing
   Identity Verifier** on the account. In the Azure portal, open the account,
   then **Identity validations**, and request a **Public** validation for the
   organisation that publishes Subspace. Microsoft checks the organisation's
   documents, which can take days.
3. When the validation is **Completed**, create a **Public Trust** certificate
   profile named as `Subspace--WindowsSigningCertificateProfile` says, from
   **Certificate profiles** in the portal or with
   `az artifact-signing certificate-profile create` (the `artifact-signing`
   CLI extension), choosing the completed validation.
4. Store the three Key Vault secrets, give the signing identity its two
   roles, and add the federated credential and environment secrets above.

Until step 3 is done, the sign job fails with an error that the certificate
profile does not exist; a `build-only` run still checks the build.

If the vault accepts only private traffic, `make sign-windows` needs a network
path to its private endpoint.

## Install a release

The install scripts download the asset for this machine with the
[GitHub CLI](https://cli.github.com) (`gh auth login` first), check its
SHA-256 checksum, and install Subspace for the current user. They need the
repository that holds the release. They default to
`aiconsultancy/subspace` and consider only published, stable
tags from the Subspace tag stream. To install a pre-release, see
[Install a pre-release](#install-a-pre-release). Latest selection searches the newest 100 repository
releases; use an explicit version if the desired release is older.

Linux, macOS and Git Bash on Windows:

```bash
sh scripts/install-release.sh                   # newest release
sh scripts/install-release.sh --version 0.1.0   # one version
```

PowerShell:

```powershell
./scripts/install-release.ps1
./scripts/install-release.ps1 -Version 0.1.0 -BinDir C:\tools\bin -NoPath
```

Release tags are `subspace-desktop-v<version>`. Release assets are the archives
and `.sha256` files above.

These scripts are an alternative to download-and-copy installation. After
that, update with `subspace upgrade`. See
[Update an installed app](#update-an-installed-app).

| System | Install directory |
| --- | --- |
| Linux | `~/.local/bin` |
| macOS | `~/Applications/Subspace.app`; CLI symlink in `~/.local/bin` |
| Windows | `%LOCALAPPDATA%\Programs\subspace`, added to the user `PATH` |

On macOS, the installer downloads the signed, stapled app ZIP. `--bin-dir`
(`-BinDir`) or `SUBSPACE_BIN_DIR` changes the CLI symlink directory; it does not
change `~/Applications`. On Linux and Windows, the same option changes the
binary install directory.
Other options: `--repository` (`-Repository`), `SUBSPACE_VERSION`, and
`-NoPath` on Windows.

To install without a release, copy the binary from a package:

```bash
tar -xzf dist/subspace-0.1.0-x86_64-unknown-linux-gnu.tar.gz -C ~/.local/bin subspace
```

## Pre-releases

The `Subspace pre-release` workflow (`.github/workflows/subspace-prerelease.yml`)
builds Subspace pre-releases from `main`. A pre-release has a type:

| Type | Trigger |
| --- | --- |
| `nightly` | Schedule, every day at 02:00 UTC |
| `alpha`, `beta` | Manual run (**Run workflow**) on `main` |

The manual form has two inputs: `type` (`alpha` or `beta`) and `force`. The
workflow fails before it builds for any other branch, event or type.

The workflow builds only when there is no earlier release of the same type, or when a commit since that release changed a path that the
stable release workflow watches. Set `force` to build a manual release
without changes. A skipped build is shown in the run summary, and the run
succeeds.

The version is `<base>-<type>.<id>.g<hash>`, for example
`1.10.2-nightly.202611010200.ga43a333`:

- `<base>` is the newest published stable Subspace release plus one patch.
- `<id>` is the UTC time when the run was created, `YYYYMMDDHHMM`. A re-run
  keeps the same version.
- `<hash>` is the first 7 characters of the built commit.

The tag is the stable prefix plus the version, for example
`subspace-desktop-v1.10.2-nightly.202611010200.ga43a333`. The release title is
`<Display name> <version>`, for example `Subspace (Nightly) 1.10.2-…`.

The pre-release has the same targets and asset kinds as a stable release. The
macOS app archive uses the type in its name, for example
`Subspace-Nightly_<version>_darwin_arm64.zip`. The macOS app is signed,
notarized and stapled in the `subspace-macos-signing` environment. A separate
gate (`scripts/prerelease-signing-allowed.sh`) allows signing only for a valid
pre-release run on `main`. The stable gate does not change.

The release stays a draft until all assets are uploaded and verified. Then
it is published as a pre-release that is not marked Latest. The release notes
list the changes since the previous release of the same type. After
publication, the workflow keeps the 3 newest pre-releases of each type and
deletes older ones with their tags. It never deletes a stable
release.

Pre-release runs of one type run one at a time. They do not share the run
queue of the stable release workflow.

## Install a pre-release

Add `--channel` (`-Channel`) to the install scripts. The channel is `stable`
(the default), `nightly`, `alpha` or `beta`. Without `--version`, the script
installs the newest published pre-release of that type. A
`--version` must be a version of the selected type.

```bash
sh scripts/install-release.sh --channel nightly
sh scripts/install-release.sh --channel beta --link
```

```powershell
./scripts/install-release.ps1 -Channel nightly
./scripts/install-release.ps1 -Channel beta -Link
```

Each type installs beside stable and does not change the stable installation:

| System | Pre-release install location |
| --- | --- |
| macOS | `~/Applications/Subspace (Nightly).app`, `~/Applications/Subspace (Beta).app` |
| Linux | `~/.local/share/<binary>-<type>/bin/<binary>` |
| Windows | `%LOCALAPPDATA%\Programs\subspace-<type>` |

The executable name does not change. Only one `subspace` command can be on
`PATH`. A pre-release install does not change `PATH` or the CLI link: it
prints the full path to the pre-release CLI. Add `--link` (`-Link`) to make
the pre-release CLI the one on `PATH`. Run the stable installer again to
point `PATH` back to stable.

### Pre-release builds

A pre-release build has its own identity and data, so stable and each type
can run at the same time:

| Item | Stable | Pre-release of type `nightly` |
| --- | --- | --- |
| Display name and window title | `Subspace` | `Subspace (Nightly)` |
| macOS bundle id | `com.aiconsultancy.subspace` | `com.aiconsultancy.subspace.nightly` |
| Config and state directory | `subspace` | `subspace-nightly` |

A pre-release build does not read stable config. Set up boards and
credentials again in each type.

The macOS `CFBundleShortVersionString` and `CFBundleVersion` hold the numeric
base version. The full version is in `product.json`, `--version` and About.

When a pre-release CLI runs a command, it writes one warning line to stderr:

```text
warning: Subspace (Nightly) 1.10.2-nightly.202611010200.ga43a333 is a pre-release build
```

The warning is not written for `--version`, `__product_metadata`, `--json`
output or the desktop app. Set `SUBSPACE_NO_PRERELEASE_WARNING=1` to hide it.

The `mcp` command uses the same default address (`127.0.0.1:7331`) in every
type. To serve MCP from two types at the same time, pass `--bind` to one.

## Open the desktop on Windows

Double-click `subspace.exe` without arguments to open the desktop. The app detaches its console before opening the window,
so a blank terminal does not remain open and closing the launching terminal
does not terminate the desktop. Windows may briefly show the console during
startup. Commands with arguments, including CLI and MCP, keep their existing
console input and output.

Desktop window-opening failures are also recorded in the app log under
the product's state directory.

## Update an installed app

After a download-and-copy or release-script installation, an app with an
update source can update itself.

Each app declares its update source in its product descriptor
(`products/descriptor/src/lib.rs`). Subspace uses repository
`aiconsultancy/subspace`.

| App | Binary | Tags | Token variable |
| --- | --- | --- | --- |
| Subspace App | `subspace` | `subspace-desktop-vX.Y.Z` | `SUBSPACE_GITHUB_TOKEN` |

An app without an update source has no `upgrade` command, About update
controls, or startup check.

Updates stay in one channel. A stable build offers only stable releases. A
pre-release build offers only newer published pre-releases of its own type,
never stable or another type. `upgrade --version` in a pre-release
build accepts only a version of its type. An update keeps the type's app name,
bundle id, install location and data.

`upgrade` is a Framework root command, like `mcp`. It is not a board command.

### CLI

```bash
subspace upgrade
subspace upgrade --check
subspace upgrade --version X.Y.Z
```

- `upgrade --check` prints the running version and the newest release. It
  does not download assets.
- `upgrade` with no options installs the newest release when it is newer.
  Otherwise it reports that the app is up to date.
- `upgrade --version X.Y.Z` installs that exact release. An older version
  is allowed.

On success the command prints the old and new versions. Open windows keep the
old version until you restart them.

### Token

The app reads a GitHub token in this order:

1. The app-specific variable (`SUBSPACE_GITHUB_TOKEN`)
2. `GH_TOKEN`
3. `GITHUB_TOKEN`
4. The account signed in with **Sign in with GitHub**: the chosen account
   when it signed in, else the first signed-in account
5. `gh auth token`

An empty variable counts as unset. If no token is available, the app
reports that the repository is private and names Sign in with GitHub,
`gh auth login` and the app-specific variable.

### Verification and install

When you select **Install update**, the updater reads fresh metadata for the selected
release version. It does not rely on the asset list cached when the update
popup opened, or switch to another version. If the archive or its checksum is
still missing, the updater reports that the release is not ready and leaves
the installation unchanged. Select **Check for updates** again later.

The app downloads the asset and its `<asset>.sha256` file. It installs
nothing if the SHA-256 digest does not match. It also checks `product.json`
id and version.

On Linux, Windows, and macOS outside an app bundle, a plain archive
install replaces the running executable. A failed replace restores the
previous file. On Windows the previous executable stays as `.old` until
the next start.

On macOS inside `Subspace.app` (the release installer
layout: app in `~/Applications`, CLI linked into a bin directory), the
app downloads the signed app ZIP, checks `product.json` and the bundle
id, runs `codesign --verify --deep --strict`, and swaps the whole bundle.
CLI links keep working.

### GUI

The About dialog has **Check for updates**. When a newer release exists,
it offers **Install update**. Once the update is installed, it offers **Quit
and restart**, which quits the app and opens the new version. It goes through
the normal quit, so the quit confirmation, when it is on, lists running
programs first. Settings shows the same button at the bottom of its left pane.

During installation, About shows preparation, download, checksum verification,
extraction, app-signature verification when applicable, and replacement stages.
The archive download shows received bytes and a progress bar when its size is
known. The bar measures only the download, not the whole installation. Unknown
sizes and verification stages show a spinner instead of an estimated percentage.

**Automatically check for updates at launch** is on by default and is available
in both About and Settings. The app checks once after the first window opens.
A newer version shows a toast. About shows the check status and any error;
failed checks do not show a toast. Startup and manual checks do not overlap.
Installation and restart remain user-triggered: nothing installs or
restarts without a click. See [Settings](settings.md#updates).
