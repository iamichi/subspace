# Changelog

Release Please adds an entry for each release of the Subspace Framework, from
the conventional commits that touch `subspace-framework/`. See
[Publishing the Framework](docs/publishing.md).

## [0.3.0](https://github.com/aiconsultancy/subspace/compare/subspace-framework-v0.2.0...subspace-framework-v0.3.0) (2026-11-20)


### Features

* **client-github:** close pull requests, recent merges and deployment statuses ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* **component-gallery:** Linux/React proof (parity incomplete: 0/6 strict) ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* **contracts:** pull request navigation, issue summaries and issue scope ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* **dashboard:** add a marked external link with a separate accessible name ([a5166af](https://github.com/aiconsultancy/subspace/commit/a5166af96ad6316a22afc1827c2c6074d88b2fc9))
* **dashboard:** find in page, reference cards, media tiles and list headers ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* **fleet-console:** add the Fleet Console web Space ([a55b749](https://github.com/aiconsultancy/subspace/commit/a55b7492eb91dff2e7387488d3c40163cb238b5d))
* **framework:** close a Space from its tab's right-click menu ([263ae6c](https://github.com/aiconsultancy/subspace/commit/263ae6cfbb6eb3b64cf9ef30ed39c6d07f641094))
* **framework:** close a Space from its tab's right-click menu ([48a2169](https://github.com/aiconsultancy/subspace/commit/48a216902d7b3e5d986affc9dd71d3c9fa900e8c))
* **framework:** count and clear the secrets a board's app saves itself ([9d127f3](https://github.com/aiconsultancy/subspace/commit/9d127f36ff3bc411f897f70cb682012d37d0d47f))
* **framework:** expose opt-in GPUI Kit text interactions ([e32d36a](https://github.com/aiconsultancy/subspace/commit/e32d36a04ed04cd1a3399474bb58a15f55b21d64))
* **framework:** let capture builds sign in with a local development provider ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* **framework:** let configured Spaces declare their type's contracts ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* **framework:** name the active theme's bundled file in a ThemeId global ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* **framework:** product credits, release repository and search quota accounting ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* **framework:** provider-neutral account sessions with Entra and WorkOS providers ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* **shell:** account settings, title prefix, last view and Linux capture ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* **web:** give web Space pages the theme, their secrets and issue tiles ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* **web:** merge the web Space bridge for Subspace API ([69aac0f](https://github.com/aiconsultancy/subspace/commit/69aac0f6fb94c0cb6bd2648a24ac4b8eb2a35c34))


### Bug Fixes

* **account:** refuse token leases while the account changes ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* **account:** release abandoned callbacks and scope WorkOS sessions ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* address the review findings for the web bridge, close Space and Fleet Console ([#6](https://github.com/aiconsultancy/subspace/issues/6)) ([aa9fd80](https://github.com/aiconsultancy/subspace/commit/aa9fd805a1f1632866b637ff0f49bceb7dbe3e88))
* **auth:** keep a rotated refresh token when a refresh goes stale ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))
* **framework:** align GPUI Kit text backport with upstream ([b80491c](https://github.com/aiconsultancy/subspace/commit/b80491cc04297b39685579c9157ce7dd96e6c9ac))
* **framework:** backport GPUI Kit text interactions ([492c80a](https://github.com/aiconsultancy/subspace/commit/492c80a48a115085da52b4693e6b72006f781498))
* **framework:** use a fictional default issue key ([668fced](https://github.com/aiconsultancy/subspace/commit/668fced458a0baeb0d4369058a8d891ba77be085))
* **issues:** recognise full-length API project keys ([93c4b78](https://github.com/aiconsultancy/subspace/commit/93c4b781466176ceb9b8f07700b0b70e9a9e8c0a))

## [0.2.0](https://github.com/aiconsultancy/subspace/compare/subspace-framework-v0.1.0...subspace-framework-v0.2.0) (2026-11-17)


### ⚠ BREAKING CHANGES

* **framework:** fill the Framework version in without ProductBuild

### Features

* **framework:** publish from CI when a release tag is pushed ([751cee2](https://github.com/aiconsultancy/subspace/commit/751cee2025cfcab42174f74e6f918b533ef3bca2))
* **framework:** show the Framework version in About ([4db2b73](https://github.com/aiconsultancy/subspace/commit/4db2b73900b30bc3ddd0f14168bbf016f849d9e6))


### Bug Fixes

* **framework:** package one checkout at a time ([351b265](https://github.com/aiconsultancy/subspace/commit/351b265f2f0493566402d34fa64a623a7f44e027))
* **framework:** package when the build cache has pruned the target folder ([04f3352](https://github.com/aiconsultancy/subspace/commit/04f3352651a8d111558652e7258512d4240ba0a0))
* **framework:** report the app's version from the mcp command ([6d371da](https://github.com/aiconsultancy/subspace/commit/6d371daade0d4d31bcddf7bd7ecf59d7ed81a681))


### Code Refactoring

* **framework:** fill the Framework version in without ProductBuild ([50bd687](https://github.com/aiconsultancy/subspace/commit/50bd6879c3fae5183f29f2ef1dcd127c59edbf2b))

## 0.1.0 (2026-11-17)

The first release, published to crates.io by hand.
