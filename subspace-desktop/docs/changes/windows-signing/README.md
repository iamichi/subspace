# Sign Windows releases with Azure Artifact Signing

Back to the [change records](../README.md).

## Intent

Releases shipped only the signed macOS app. The owner asked for the Windows
build to be signed with Azure Artifact Signing, with a make target and a
workflow, keeping every Azure resource name out of this public repository.
They asked whether signing needs a Windows VM, and wanted the builds to run on
the platform's self-hosted runners rather than GitHub-hosted ones.

## Spec

- No Windows machine is needed to sign. Artifact Signing keeps the key in
  Microsoft's HSMs and signs a digest the client sends over HTTPS. The client,
  jsign, runs on any OS. There is no certificate to store. Key Vault holds
  only the endpoint, account and certificate profile names
  (`Subspace--WindowsSigning*`).
- The build does need Windows. A GPUI release build for Windows cannot be
  cross-compiled from Linux, because the renderer compiles its shaders with the
  Windows SDK's `fxc.exe` in a build script. The jobs run on two self-hosted
  ARC scale sets in runner group `subspace-release`:
  - `subspace-windows`, a Windows Server 2022 runner on a node pool that scales
    from zero to one, builds and verifies;
  - `subspace-signing`, a Linux runner that reaches the private Key Vault, signs.
- `make sign-windows FILES=...` (`scripts/sign-windows.sh`) signs `.exe`,
  `.dll`, `.msi` and `.msix` files in place. Given a release `.zip`, it signs
  every `.exe` and `.dll` inside, keeps the entries and their order, and
  rewrites the `.sha256`.
  - Configuration comes from the environment, then from the Key Vault named by
    `SUBSPACE_SIGNING_KEY_VAULT`, which has no default.
  - It refuses an endpoint that is not Artifact Signing's.
  - It passes the access token to jsign through the environment only.
- `.github/workflows/windows-release.yml` runs when `release.yml` creates an
  app release, or by hand on `main` with a tag and a mode: `publish`,
  `sign-only` or `build-only`.
  - It builds on `subspace-windows` with no secrets.
  - It signs on `subspace-signing` in the `windows-signing` environment, using
    GitHub OIDC. The environment's deployment rule allows `main` and
    `subspace-desktop-v*` tags.
  - It verifies the signature with `Get-AuthenticodeSignature` on Windows.
  - It attaches the archive and its `.sha256`, normally to the draft release.
- The Azure identity, the vault name and the runner configuration live outside
  this repository: the identity's IDs and the vault name are in the
  environment's secrets.

## Delivery

- `bash scripts/test-sign-windows.sh` runs the script against a fake `az` and
  jsign. It is also part of `scripts/test-scripts.sh`. It covers:
  - configuration from Key Vault and from the environment;
  - the exact jsign arguments, with the token never on the command line;
  - a wrong endpoint and a missing secret;
  - archive rewriting with a valid checksum;
  - a jsign failure leaving the archive untouched;
  - an archive with nothing to sign.

  It passes under macOS's bash 3.2 and under bash 5.
- `actionlint` passes on the workflows.
- Not yet verified end to end. The certificate profile cannot exist until the
  organisation's identity validation completes in the Azure portal. The first
  `build-only` run on the Windows runner will show whether the build compiles
  there.

## Tasks

- [x] `scripts/sign-windows.sh`, its fixture test and `make sign-windows`.
- [x] `windows-release.yml` and its start from `release.yml`.
- [x] Installation guide, ways of working and agent instructions.
- [ ] Owner: identity validation in the portal, then the Public Trust
      certificate profile.
- [ ] A `build-only` run, then a `sign-only` run, of `windows-release`.
