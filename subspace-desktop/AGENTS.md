# Agent instructions for Subspace Desktop

Subspace Desktop is the Subspace App, a desktop dashboard app built with Rust
and GPUI Kit on the Subspace Framework. Read [README.md](README.md) for the
layout and how the app uses the Framework. The Framework is a separate
project in `../subspace-framework` with its own
[AGENTS.md](../subspace-framework/AGENTS.md); its rules apply to every Space
here.

## Documentation

Start each session at the [documentation index](docs/README.md). It lists
every page by area with a one-line summary; read the pages relevant to the
task rather than all of them. When you add a page under `docs/`, link it from
the index or a page it links; `make check` fails otherwise.

Follow [Ways of working](docs/ways-of-working.md): conventional commit
messages (`type(scope)!: summary`), one logical change per commit, and
semantic versioning in which any `feat` since the last release bumps the
minor version.

## Before every commit and push

Load the `developer-checklist` skill
([.agents/skills/developer-checklist](.agents/skills/developer-checklist/SKILL.md))
and work through it before every commit, every push and every pull request,
including merges into `main`. It checks that the prek hooks are installed,
classifies the change (UI, board, framework, contracts, settings,
dependencies, docs, release) and routes each kind to the rules it must
follow. Do not commit or push until every item that applies is done.

## Canonical design and coding guides

Load and use both `gpui-kit-design-guides` and `gpui-kit`, in
`.agents/skills/` here (the Framework keeps its own copy). If either skill is
missing, install that skill from
[`longbridge/gpui-kit`](https://github.com/longbridge/gpui-kit.git).

Before changing UI, interaction, interface language, layout, styling,
components, or application architecture, read and follow the canonical guides:

- [Design Guides](https://gpui-kit.com/docs/design-guides.md)
- [Coding Guides](https://gpui-kit.com/docs/coding-guides.md)

Read the guide files themselves, not only the skill summaries. These guides are
requirements, not optional inspiration. Do not copy generic web conventions,
infer a design system from one existing screen, or add a control merely because
the underlying feature exists. Preserve the documented task hierarchy,
interaction promise, desktop conventions, spacing, alignment, theme tokens,
component boundaries, naming, and crate architecture.

Review the finished work against both guides before considering it complete.

## Terminology

The **Subspace Framework** is the reusable crates in `../subspace-framework`
that an app is composed from, imported as one crate, `subspace-framework`. An
**App** is a binary built from the Framework with a selected set of boards
(code: *product*). The **Subspace App** is `subspace` (`Subspace.app`). See
the [glossary](docs/glossary.md) and the
[Framework glossary](../subspace-framework/docs/glossary.md).

**Space** is the current name for a **board**; the terms are
interchangeable. A Space is an alias for a board, so every rule here about
boards applies to Spaces. Prefer Space in new text, docs and names. Existing
references to boards are fine and need not be renamed. The IRC Space is
**Channels** (board id `irc`).

## Commands

Use the make targets. Plain `make` lists them, in this directory or at the
repository root; the root `Makefile` runs `check` in both projects and
forwards the app's targets here.

- `make test` for the tests, `make check` before reporting work as done
  (architecture, board-guide and documentation-index checks, format check,
  unused-dependency check with cargo-shear, clippy with warnings denied, tests
  and script fixtures).
- `make build`, `make run`, `make format`.
- `make interfaces` checks the real headless product interface.
- `MISE_ENV=terminal make check-terminal` checks the excluded terminal crates
  with Zig.
- `make install-macos` builds and installs an ad hoc signed app;
  `make package-macos` builds a signed, notarized one; `make release-macos`
  also publishes it (see Releases).
- In non-interactive shells, run Cargo through mise (`mise exec -- cargo ...`)
  so builds use the Mr Boxington cache.
- prek runs the hooks (`make hooks` installs them). Commits run file hygiene,
  the format check and gitleaks; pushes run `make check` and
  `mise run quality`. The hooks refuse commits to `main`. Vendored files and
  `.agents/skills` keep their upstream bytes.
- After moving or renaming the workspace folder, run `cargo clean`: Cargo
  does not rebuild tests that embed their old absolute `CARGO_MANIFEST_DIR`.

## Structure

- This folder is a project of its own: its own Cargo workspace, lockfile,
  checks, docs and baseline. Installable web Space packages live under
  `web-spaces/` (examples in `web-spaces/examples/`); the `web-space` skill
  ([.agents/skills/web-space](.agents/skills/web-space/SKILL.md)) scaffolds,
  tests and packages them.
- **One import.** Every crate here reaches the Framework only through
  `subspace-framework` and writes `subspace_framework::<module>::…`. No crate
  names another Framework crate. The workspace dependency is
  `subspace-framework = { path = "../subspace-framework", version = "0.2.0" }`;
  deleting `path` (here and in the two terminal manifests, then refreshing
  the three lockfiles) switches to the published crate, as the Framework's
  [publishing guide](../subspace-framework/docs/publishing.md#subspace-desktop-and-the-published-crate)
  describes. The architecture check accepts either form and permits
  `markdown` and `gpui-base` patches from the Framework's `vendor/` or from
  this folder's own copies. While the path is in place,
  `scripts/prerelease-plan.sh` counts Framework commits as app changes
  (a git pathspec, not a file read).
- **Three cross-folder paths** live in `Cargo.toml`. They point to the facade,
  `../subspace-framework/vendor/markdown` and `../subspace-framework/vendor/gpui-base`.
  Framework consumers copy the Markdown patch, and apps enabling
  `gpui-kit-text-patch` also copy the `gpui-base` patch. The two excluded
  terminal manifests declare their paths directly, because an excluded
  workspace cannot inherit them. No script, test, build script, doc check,
  `include_str!` or `#[path]` here reads the Framework's folder. Docs may link
  to Framework pages with relative links, which the doc checks treat as
  external.
- Layout and dependency direction (products → Spaces → `subspace-framework`):
  - `spaces/<id>/` holds the Spaces, named `subspace-<id>-board`, with
    Space-owned support crates under `spaces/<id>/crates/`. A Space depends on
    `subspace-framework` (default features, or `agent`), its own crates and
    desktop clients, never on another Space, a product or the terminal.
  - `clients/` holds the desktop's service clients (`irc`, `subspace-api`). Clients
    depend on clients and `subspace-framework` only.
  - `products/` holds the thin app binary (`products/subspace`, whose
    `build.rs` stamps the build) and the app's
    product descriptor with the packaging metadata helper
    (`products/descriptor`, package `subspace-descriptor`). Products may
    depend on anything here and enable any facade feature.
  - `terminal/` holds the terminal panel (`terminal/panel`), its runtime
    (`terminal/runtime`) and the Zig-free Ghostty configuration parser
    (`terminal/ghostty-config`). The panel and runtime need Zig, so they are
    excluded workspaces with their own lockfiles and the product reaches them
    through its `terminal` feature; `ghostty-config` is a workspace member.
    They stay here, not in the Framework, because `libghostty-vt` is a git
    dependency, which crates.io refuses. The shell docks the panel through
    the Framework's `dashboard::dock_panel` contract and
    `ProductBuild::dock_panel`.
  - Only products may enable the facade's `host` or `capture` features or
    name its host modules (`shell`, `board_command`, `chat`, `mcp`,
    `report_issue`, `search_ui`, `update`). `test-support` is for
    dev-dependencies only. Cargo unifies features across a workspace build,
    so the architecture check enforces this rather than the compiler.
- `mise run architecture`, also run by `make check`, checks these rules from
  Cargo metadata for this workspace and both terminal workspaces, the patch
  tables, and source includes (including tests and examples), the `PATH`
  lookup rule (`find_tool`; exemptions in `scripts/architecture_source.py`),
  the switch and icon-button rules, and that products never source-include
  Space files. The Framework checks its own layers with its own copy.
- Adding a Space is one new crate, one dependency line in each selected
  product package and one `BoardRegistration` in its entrypoint, plus a
  `BoardDescriptor` in `products/descriptor`. Complete the Framework's
  [board checklist](../subspace-framework/docs/board-checklist.md) for every
  new or changed Space
  ([what the Framework gives a board](../subspace-framework/docs/board-integration.md)).
- Boards communicate with each other only through contracts routed by the
  Framework's broker; record the declared roles in
  [the Spaces audit](docs/spaces-audit.md#declared-contracts), which a product
  test compares with the registrations.
- `clients/irc` is the IRC and IRCv3 runtime used by `spaces/irc` and is
  licensed Apache-2.0 like the rest of the workspace. Its protocol, connection
  and session modules were written in a clean room. Keep them independent of
  code from other IRC clients and libraries, including Halloy
  (GPL-3.0-or-later). [Clean-room log](clients/irc/CLEANROOM.md)
- Client calls block: run them in `cx.background_spawn`, never in render.
- GitHub credentials resolve in this order: environment, config file, an
  in-app Sign in with GitHub account (Keychain), then the `gh` CLI; keep it.
- **Build configuration.** The Framework holds no OAuth App and no issue
  repository. `products/subspace/build/config.rs` holds Subspace's (the
  OAuth App's client id and `aiconsultancy/subspace`); `build.rs` emits them
  and re-runs when `SUBSPACE_GITHUB_OAUTH_CLIENT_ID`,
  `SUBSPACE_GITHUB_OAUTH_CLIENT_SECRET` or `SUBSPACE_REPORT_ISSUE_REPOSITORY`
  changes (empty turns Sign in with GitHub or Report issue off), and
  `main.rs` passes them through `ProductBuild`. The secret is read with
  `option_env!` only: never print it, log it or emit it from the build
  script. Report issue is the product's default `report-issue` feature.
- **Identity and API configuration.** `products/subspace/build-config.json`
  (or the file `SUBSPACE_BUILD_CONFIG` names) selects the identity provider
  (`dev`, `workos`, `entra` or none), the Subspace API URL and optional
  branding; `build/branding.rs` validates and embeds it, and
  `src/identity.rs` builds the provider, letting the same-named `SUBSPACE_*`
  variables override it at run time. The checked-in config is the local
  development stack (`dev` sign-in against `http://127.0.0.1:3000`). Never
  commit a real tenant, client ID or private API URL; see
  [Identity providers and the API URL](README.md#identity-providers-and-the-api-url).
- **A Framework change and a Space change together.** Both projects live in
  this repository, and the desktop builds the Framework from
  `../subspace-framework` by path, so an edit there is in the next desktop
  build. Make the Framework change first, run `make check` there, then the
  Space change here and `make check` here (or `make check` at the repository
  root for both). Commit them separately: the Framework commit first, scoped
  to the Framework. Once the Framework is published and the path removed, a
  Framework change reaches the desktop only through a new release and a
  version bump here.

## Components

The Framework's [component rules](../subspace-framework/docs/ui-components.md#rules)
apply to every Space here: use a GPUI Kit component as it ships, themed by
tokens, through its shared treatment; otherwise a shared component in the
Framework's board kit; draw a custom element only with a recorded reason.
Everything visible is a component: no one-off styled controls in Spaces. A
shared component belongs in the Framework, with its Component gallery card.

## Space layout

Use the Issues Space as the reference when adding a list-based Space or tab,
including one in a new UI crate. Start with the Space name and a short line of
service, account or status context when it helps the user. Place tabs and
filters below the heading. Give the header, controls and list a shared leading
edge, and use the comfortable row spacing from Issues.

Check the layout in a narrow window. Keep primary controls easy to find and
use the shared overflow toolbar for controls that need more room. Follow the
[Framework layout guidance](../subspace-framework/docs/board-integration.md#layout-and-ui)
for the components and hooks.

## Conventions

- Use edition 2024, the workspace dependencies and lints, and `gpui-kit` as
  the one GPUI dependency. The workspace manifests are the source of truth.
- Import GPUI through `gpui_kit`. In test modules, import names explicitly
  rather than `use super::*`, because the glob brings GPUI's `test` macro,
  which shadows `#[test]`.
- No `unwrap` or `expect` outside tests and startup.
- New tabs and action buttons should always have an appropriate glyph by
  default. Every control still needs an accessible label. Treat the glyph as
  decorative unless it communicates status that the label does not.
- Use shared `IconButton::latched(bool)` for independent on/off toolbar modes.
  Use `toggle::switch` for booleans in forms, settings and dialogs, including
  settings panels opened from toolbars. In forms, use `toggle::toggle_row` with
  the label on the left and switch on the right. Preserve the owner's existing
  Save or immediate-apply boundary; Settings switches edit drafts until Save.
  Keep exclusive selection, task completion, disclosure and checked menu items
  in their native semantic controls. Do not restyle switches at call sites.
- Keep pure logic (grouping, selection, filters) out of render code and test
  it. Test observable interaction and critical layout invariants, not incidental
  rendering details.
- Record changes under `docs/changes/<slug>/` (intent, spec, delivery, tasks).
- Do not commit, push or add a remote unless the owner asks.

## UI change evidence

Every change that alters what Subspace shows needs screenshots
inline in the pull request description. This includes layout, styling,
controls, icons, themes and interface text. A UI change without them is not
ready for review. Headless render tests are still required; screenshots do
not replace them.

- Capture from an isolated dev build of the branch, using fixture data. Do not
  use your installed apps, real configurations, real hostnames, real people's
  names or credentials.
- Capture only with `make capture OUT=<dir> STEPS='<steps>'`
  (`scripts/capture.sh`). Never launch a capture build yourself or write your
  own capture script: `open` passes your environment to the app, and
  `XDG_CONFIG_HOME` alone exposes the real gh accounts even with an isolated
  `HOME`. The script builds the debug-only capture build and starts it in the
  background from an empty environment with a new `HOME` and XDG folders, the
  fictional `octo-dev` gh accounts, and the fictional GitHub
  (`scripts/github_test_server.py`) and Subspace API servers on loopback, so no real
  API or Keychain session is used. Options are in the script's header:
  `CAPTURE_THEME`, `CAPTURE_STATE`, `CAPTURE_CONFIG` (such as enabled boards)
  and `CAPTURE_IRC_CONFIG` for a config naming the local Ergo server from
  `scripts/irc-test-server.sh` (`127.0.0.1:16667`). The build runs in your
  environment, so `SUBSPACE_REPORT_ISSUE_REPOSITORY= make capture …`
  captures a build without Report issue.
- `STEPS` is a `;` list of `wait:<ms>`, `action:<name>` (for example
  `subspace_app::OpenSettings`), `click:<x>,<y>`, `right-click:<x>,<y>`,
  `move:<x>,<y>` (the pointer without a click, for hover states),
  `drag:<x1>,<y1>,<x2>,<y2>` (a left-button drag, for text selection),
  `scroll:<x>,<y>,<dy>`, `type:<text>` (each character as a key press),
  `key:<keystrokes>` (space-separated, such as `down tab`),
  `drop:<x>,<y>,<fixture-path>` (a synthetic file drop at that point),
  `installed:<version>` (the updater as if that update had just installed,
  installing nothing) and `shot:<name>`.
  The app captures its own windows to PNG without screen-recording permission,
  then quits. macOS uses GPUI image rendering; Linux reads its native window
  on a private Xvfb display. See [Desktop capture](docs/capture.md). Never steal focus, move the pointer or type into
  the foreground; if a state needs it, ask first.
- Capture starts on the first Space unless `CAPTURE_STATE` sets
  `app.dashboard` to a Space id. `action:` dispatches from the window's app
  root regardless of focus, and an unknown action or one without a root handler
  fails with `capture failed` and a non-zero exit. Keys go to the focused
  element: each `key:` step first focuses the active Space, then sends the
  whole sequence, so keys such as Tab can change focus within that sequence.
  `type:` preserves focus; click the composer before typing into it.
- A web Space's page is a native web view, which GPUI's window image does
  not contain. On macOS a capture build draws a snapshot of the page over it
  and forwards `click:` and `move:` steps on it to the page as DOM pointer
  events (`spaces/web/src/mirror.rs`); keys do not reach the page. The page
  is also told it is visible, because the capture window sits behind others.
  `CAPTURE_CONFIG` can install a folder web Space with its grants and
  secrets; `CAPTURE_FLEET=1` adds the neutral `FLT` project whose issues
  such a page can reference.
- Capture in Cupertino Dark, the default theme: leave `appearance.theme`
  unset in the fixture state. Capture other themes only when the change is
  about a theme, colour or contrast.
- Show each changed state:
  - For a change to existing UI, show before (an `origin/main` build) and
    after, side by side or as a pair.
  - For a setting with variants, show each variant.
  - For a theme, colour or contrast change, show each affected theme, in its
    light and dark variants.
- Store the images as PNG under `docs/changes/<slug>/evidence/`. Make each one
  at most 1600 px wide.
- Embed each image in the pull request description with a commit-pinned URL
  and a one-line caption that says what it shows:
  `![caption](https://github.com/aiconsultancy/subspace/blob/<commit-sha>/subspace-desktop/docs/changes/<slug>/evidence/<file>.png?raw=true)`.
  GitHub has no API to upload pull request attachments, and relative paths do
  not render in a description.
- Examine each image before you push. If it shows internal hostnames,
  subscription data, tokens or real names, do not commit it. Capture it again
  with fixture data.
- If you cannot capture a screenshot, do not mark the pull request ready. Say
  what blocks the capture and ask for help.
- Integration merges into `main` count too: embed each included change's key
  images, or link the pull requests that carry them. `gh pr create --body`
  skips the pull request template, so copy its sections into the body.

## Branches and worktrees

- Subspace lives at `subspace-desktop` in `aiconsultancy/subspace`.
  Run its Cargo and make commands from that directory.
- Work on a repository branch and merge through pull requests; do not push or
  merge directly into `main`.
- GitHub workflows: `.github/workflows/release.yml`
  runs Release Please on every push to `main`, nightly (when it also merges
  the Framework's release pull request) and by hand as a dry run;
  `publish-framework.yml` publishes the Framework's crates when
  `release.yml` starts it on a new `subspace-framework-v*` tag (see the
  Framework's publishing guide); `packslip.yml` signs each published desktop
  release with packslip (see the installation guide); `windows-release.yml`,
  which `release.yml` starts for each new app release, builds the Windows
  archive on the Subspace self-hosted ARC runners (a Windows pool scaling
  from zero), signs `subspace.exe` with Azure Artifact Signing and
  attaches it. None of them tests the app: `make check` and
  `mise run quality` are the gate; the prek
  pre-push hook runs both, and the root `make release-check` covers the
  release tooling.
- Release Please's pull requests (`release-please--branches--main--components--*`)
  are the only commits that change a version; review and merge them on
  `main`. After a release, `release.yml` fast-forwards
  `feat/subspace-desktop` to `main` when it can, and says in its job summary
  when it cannot.

## Releases

- Release Please (`release-please-config.json` and
  `.release-please-manifest.json` at the repository root) owns the version,
  `[workspace.package] version` in `Cargo.toml` and the two terminal
  manifests, and `CHANGELOG.md`. Never bump a version by hand. Its release
  pull request, `chore(subspace): release X.Y.Z`, follows
  [Versioning](docs/ways-of-working.md#versioning) and carries the
  lockfiles, which `release.yml` refreshes with `scripts/sync-lockfiles.py`.
  Tags are `subspace-desktop-vX.Y.Z`.
- Merging that pull request (by hand) tags the merge commit and creates a
  draft release with the changelog's notes. Then, on the tag,
  `make release-macos [SIGNING_IDENTITY=...] [KEYCHAIN_PROFILE=...] [DRAFT=1]`
  checks that `gh` is signed in, the tree is clean, the commit is on GitHub,
  the release is a draft and its tag is `HEAD`, then builds, signs,
  notarizes and staples the app, attaches
  `Subspace_<version>_darwin_arm64.zip` and its `.sha256` file and publishes
  the release (`DRAFT=1` leaves it a draft; `RELEASE_NOTES_FILE` replaces
  the notes). It never changes a published release. The Makefile defaults to
  the team's Developer ID identity and the `subspace-notary` Keychain profile;
  the command line overrides either. Certificates, keys and notary passwords
  stay in the Keychain, never the repository.
- Signing needs the desktop login session. `make release-macos` and
  `make package-macos` run themselves there through
  `scripts/desktop-session.sh` (a one-off launchd agent in `gui/<uid>`, no
  window) when started from any other shell. Do not open Terminal windows to
  reach it.
- Publishing the release starts `.github/workflows/packslip.yml`, which
  attaches `packslip.subspace-desktop.sigstore.json`, a keyless packslip
  signed by that workflow. After a release, check the workflow run succeeded
  (`gh run list -R aiconsultancy/subspace -w packslip`). Sign every release
  from that one file; `gh workflow run packslip.yml -f tag=<tag>` re-signs one.
- Creating the app release also starts `.github/workflows/windows-release.yml`,
  which attaches `subspace-<version>-x86_64-pc-windows-msvc.zip` with an
  Authenticode-signed `subspace.exe` and its `.sha256` file. Its sign job
  uses the `windows-signing` environment's Azure identity and Key Vault;
  `make sign-windows` (jsign) does the signing anywhere. Keep the signing
  account, certificate profile and identity out of the repository; they live
  in that environment's secrets and the Key Vault. See
  [Sign Windows releases](docs/installation.md#sign-windows-releases).
- `scripts/install-release.sh` and `install-release.ps1` install releases from
  `aiconsultancy/subspace`. `make package` still builds archives for Linux
  x64, macOS ARM64 and Windows x64.
- The pre-release scripts (`prerelease-*.sh`) and `release-signing-allowed.sh`
  were written for GitHub workflows this repository does not have. Keep their
  tests passing; do not rely on them.
- Build-time `SUBSPACE_RELEASE_CHANNEL` selects the channel identity and data
  locations; stable values must not change.

## Product documentation

- Give each Subspace-based app its own section at
  `docs/<product-id>/index.md` with a `toc.yml` in the same directory, and add
  it to the root `toc.yml`.
- Lead each landing page with browsing that product's stable releases,
  downloading the platform archive and copying or extracting the app. Reuse
  the shared quick-start includes under `docs/subspace/includes/`. Keep scripts
  and CLI installation behind **Other ways to install** on the shared
  installation page. Do not use the repository-wide `/releases/latest` link.
- Link to the shared installation reference and board-owned Help guides rather
  than copying their workflows.

## Dependency audit

- Run `mise run audit` after a dependency change. It runs `cargo deny check
  advisories` on all three lockfiles: this workspace and both excluded
  terminal workspaces. It needs the network, so it is not part of
  `make check`. The Framework audits its own lockfile.
- `deny.toml` lists each accepted advisory
  with its blocking dependency chain, its reason and a review date. Do not add
  an entry for an advisory that a compatible update fixes. When the blocking
  parent moves, update it and delete the entry.

## Code Quality Rules

- Run `mise run quality` after making changes. It compares the workspace with
  `rustqual-baseline.json` and fails only when the quality score drops below
  the baseline. The prek pre-push hook runs the same task.
- The check compares the overall score only. A new finding that leaves the
  rounded score unchanged can still pass, so run `rustqual . --findings` and
  do not add findings in the code you touch.
- After you fix findings, run `mise run quality-baseline` and commit the
  updated `rustqual-baseline.json`. Never refresh the baseline to hide a
  regression.
- rustqual runs with its built-in configuration. Do not add a `rustqual.toml`
  (`rustqual --init` writes one with stricter magic-number rules).
- `mise install` builds rustqual from source. The first install takes about a
  minute.
- Follow IOSP: every function is either an Integration (calls other functions, no own logic) or an Operation (contains logic, no calls to project functions). Never mix both.
- Keep functions under 60 lines and cognitive complexity under 15.
- Don't duplicate logic — extract shared patterns into reusable Operations.
- Don't introduce functions with more than 5 parameters.
- Every test function must contain at least one assertion (`assert!`, `assert_eq!`, etc.).
- For public-API functions that are intentionally untested in this crate, mark with `// qual:api` instead of writing a stub test.
