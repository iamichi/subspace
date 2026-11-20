# Changelog

Release Please adds an entry for each release of the Subspace App, from the
conventional commits that touch `subspace-desktop/`. See
[Releases](docs/ways-of-working.md#releases).

## [0.10.0](https://github.com/aiconsultancy/subspace/compare/subspace-desktop-v0.9.0...subspace-desktop-v0.10.0) (2026-11-20)


### ⚠ BREAKING CHANGES

* **issues:** Issues reads Subspace API instead of NETT.

### Features

* **channels:** initiatives, fleets, attachments, PR chips and captain notices ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **client-subspace-api:** read an issue's decisions and one decision in the hub ([e0ab042](https://github.com/aiconsultancy/subspace/commit/e0ab0425d8070ef07250ebf64a5ad3a6670c8363))
* **component-gallery:** add React proof and strict pixel comparison ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **component-gallery:** implement full React inventory and fix review interactions ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **component-gallery:** Linux/React proof (parity incomplete: 0/6 strict) ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **desktop:** configurable identity provider and Subspace API URL ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **desktop:** show dev sign-in in captures of the local stack ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **fleet-console:** add the Fleet Console web Space ([a55b749](https://github.com/aiconsultancy/subspace/commit/a55b7492eb91dff2e7387488d3c40163cb238b5d))
* **fleet-console:** add the Fleet Console web Space ([ebdbc7d](https://github.com/aiconsultancy/subspace/commit/ebdbc7d1a826e466e1b4957fcd46dbf3615b4043))
* **framework:** close a Space from its tab's right-click menu ([263ae6c](https://github.com/aiconsultancy/subspace/commit/263ae6cfbb6eb3b64cf9ef30ed39c6d07f641094))
* **irc:** add protocol acceptance coverage and provenance ([c34397d](https://github.com/aiconsultancy/subspace/commit/c34397d0da99e36477869a2c83f8c11c748f7994))
* **irc:** replace the protocol layer with a clean-room implementation ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **issues:** add the Decisions tab and decision panel to issues ([678ddef](https://github.com/aiconsultancy/subspace/commit/678ddefe1da3bb65ce3ea00d6668293edf16a9f5))
* **issues:** Subspace API client and Issues Space replace NETT ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **prs,actions:** close pull requests, PR navigation and Actions filters ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **web:** add the secrets and issues app permissions ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **web:** give app pages the theme, their secrets and issues ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **web:** give web Space pages the theme, their secrets and issue tiles ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **web:** install the Weather example from the release repository ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **web:** let app pages save secrets of their own ([1134779](https://github.com/aiconsultancy/subspace/commit/113477981e59baf2cd2b91489e898feedb172e74))
* **web:** merge the web Space bridge for Subspace API ([69aac0f](https://github.com/aiconsultancy/subspace/commit/69aac0f6fb94c0cb6bd2648a24ac4b8eb2a35c34))
* **web:** show web Space pages in capture screenshots ([dbba1dd](https://github.com/aiconsultancy/subspace/commit/dbba1dd0cd56fbeabb615e239a594eafc6812291))


### Bug Fixes

* address the review findings for the web bridge, close Space and Fleet Console ([#6](https://github.com/aiconsultancy/subspace/issues/6)) ([aa9fd80](https://github.com/aiconsultancy/subspace/commit/aa9fd805a1f1632866b637ff0f49bceb7dbe3e88))
* **api-client:** preserve sign-out and fixture stream auth ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **build:** isolate desktop stamp Git discovery ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **capture:** start fixtures with macOS Bash ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **channels:** honour initiative channel separators and fleet routes ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **client-subspace-api:** re-read decisions from the first page on refresh ([fa7abad](https://github.com/aiconsultancy/subspace/commit/fa7abaddeae46f4bb1938aee78c82d37314af6c9))
* **component-gallery:** align fixture fills and text layout ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **component-gallery:** isolate Linux browser test session ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **desktop:** reload API Spaces after the startup dev sign-in ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **desktop:** require the signing Key Vault name from the environment ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **desktop:** restore Copy link and selectable find matches ([ed91db6](https://github.com/aiconsultancy/subspace/commit/ed91db62679794b01fc0e57c08c5769e88813d25))
* **dev-auth:** advance the generation when sign-in commits ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **dev-auth:** omit unset identity fields ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **irc:** bound open batches and buffered messages ([4709f99](https://github.com/aiconsultancy/subspace/commit/4709f99f2e55c98893971cae9a8cb070dcb9a206))
* **irc:** declare the Rust 1.99 toolchain floor ([2108350](https://github.com/aiconsultancy/subspace/commit/21083500a7bb32d9bc5e085cf9384fa0e1af393b))
* **irc:** document round-two limits and empty tag keys ([1ca363b](https://github.com/aiconsultancy/subspace/commit/1ca363b856bf61ff9a244b717a81b561fbaa5a44))
* **irc:** keep a fleet's own network in loopback capture ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **irc:** keep initiative autojoin off while its fleet is unresolved ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **irc:** rate-limit automatic CTCP replies ([693e688](https://github.com/aiconsultancy/subspace/commit/693e6886cc25819fdc4cc3919b05008edc5d7fd3))
* **irc:** stop exhausted nickname registration attempts ([37ea248](https://github.com/aiconsultancy/subspace/commit/37ea248d5a04b18ba720bfdb7959953a44b03900))
* **irc:** time out blocked socket writes ([267446f](https://github.com/aiconsultancy/subspace/commit/267446f11531657febe8314cc51e9111ee64d3fa))
* **irc:** time out stalled SASL registration ([8639ebd](https://github.com/aiconsultancy/subspace/commit/8639ebd488486789e76bf795960e11286ff95312))
* **issues:** describe decisions in the API's decided-on order ([eeb81f0](https://github.com/aiconsultancy/subspace/commit/eeb81f0460c33f398872a68cdb26e2750b1ac575))
* **issues:** keep keyboard and assistive focus usable in the decision panel ([bab1da6](https://github.com/aiconsultancy/subspace/commit/bab1da6059a2a2a6636517cbdf29cf949f540f05))
* **issues:** recognise full-length API project keys ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))
* **issues:** restart the hidden hub when the account changes ([a2d27df](https://github.com/aiconsultancy/subspace/commit/a2d27df61d9931eb59c400b03e8c0b6dcab39bed))

## [0.9.0](https://github.com/aiconsultancy/subspace/compare/subspace-desktop-v0.8.0...subspace-desktop-v0.9.0) (2026-11-17)


### ⚠ BREAKING CHANGES

* **framework:** Framework crates are imported through subspace_framework; subspace-desktop/framework is gone. make check is repaired in the next commit.

### Features

* **actions:** show per-repository loading and empty states ([72d68ea](https://github.com/aiconsultancy/subspace/commit/72d68ea38030fca622d06e5a7ad0f6a7d8081a34))
* **desktop:** set Subspace's OAuth App and issue repository at build time ([d7deeee](https://github.com/aiconsultancy/subspace/commit/d7deeee33c7ab95c82c5bce6109ec7837b8e3ecc))
* **irc-client:** report nickname metadata status ([#70](https://github.com/aiconsultancy/subspace/issues/70)) ([15492c6](https://github.com/aiconsultancy/subspace/commit/15492c608765392f1e1995f9705e8cdddf526e08))
* **issues:** give the list and issue page more space ([cb31f20](https://github.com/aiconsultancy/subspace/commit/cb31f20cf3de8d35cb781ab0656b2114fd21ed1e))
* **issues:** group terminal states in one workflow stop ([b63dde2](https://github.com/aiconsultancy/subspace/commit/b63dde26f431c240490fc51d867dda1f79f5df42))
* **issues:** preview text and Markdown attachments ([11ab599](https://github.com/aiconsultancy/subspace/commit/11ab59947fea6516677d4477aeeb345a77289621))
* **subspace:** show the Framework version in About ([728fbe2](https://github.com/aiconsultancy/subspace/commit/728fbe2c63f80d5f493ad56e5099157e6310caf6))


### Bug Fixes

* **capture:** route actions and keys past focused composers; align Channels issue help ([#64](https://github.com/aiconsultancy/subspace/issues/64)) ([ed7ee3a](https://github.com/aiconsultancy/subspace/commit/ed7ee3ac087efdb660807037db6654a44b7fe725))
* **channels:** send larger drafts on multiline connections ([60209e7](https://github.com/aiconsultancy/subspace/commit/60209e76eed0373731d4e722412a483088ff2de1))
* **issues:** supply the app's Linear workspace to issue-link recognition ([ce89fb2](https://github.com/aiconsultancy/subspace/commit/ce89fb2bd15b52467b7c942d813a935d7ff21547))
* **update:** require credentials for the selected account ([f323709](https://github.com/aiconsultancy/subspace/commit/f323709c32bca58a8a7d22b404ee6ec37b8906cb))
* **update:** respect the selected GitHub account ([743dad2](https://github.com/aiconsultancy/subspace/commit/743dad2d512a3550857f84c7f06323e5e99e6a18))


### Code Refactoring

* **framework:** split the Framework into its own workspace and crate ([6acbeb6](https://github.com/aiconsultancy/subspace/commit/6acbeb6fd46326e6c94a156e46f60a8e29bd32b6))

## 0.8.0 (2026-11-16)

The last release before Release Please. It and earlier releases are described
in their [GitHub releases](https://github.com/aiconsultancy/subspace/releases/tag/subspace-desktop-v0.8.0).
