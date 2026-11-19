.DEFAULT_GOAL := help

SIGNING_IDENTITY ?= Developer ID Application: Thoughtsun Limited (576985M4ZN)
KEYCHAIN_PROFILE ?= subspace-notary
FEATURES ?=
OUT ?=
STEPS ?= wait:5000;shot:main

.PHONY: help build update-deps test interfaces run capture check check-terminal format fmt-check lint package package-macos release-macos package-macos-ci install-macos generate-icons check-icons cache-stats clean

help: ## Show available targets
	@printf "Available targets:\n"
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_.-]+:.*## / {printf "  %-16s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build every crate
	mise run build

update-deps: ## Update Cargo.lock to the latest compatible dependencies
	mise run update-deps

test: ## Run the tests
	mise run test

.PHONY: web-bridge-test
web-bridge-test: ## Test the web Space JavaScript bridge without a browser
	mise run web-bridge-test

.PHONY: package-web-space
package-web-space: ## Validate a web Space folder and write a ZIP (SPACE=<folder> [OUT=<file.zip>])
	@test -n "$(SPACE)" || { echo "usage: make package-web-space SPACE=<folder> [OUT=<file.zip>]" >&2; exit 2; }
	mise run package-web-space -- "$(SPACE)" $(if $(OUT),"$(OUT)")

interfaces: ## Check the product CLI without a GUI or live services
	mise run interfaces

run: FEATURES = terminal
run: ## Run the debug desktop app with the terminal (FEATURES= without it)
	MISE_ENV=$(if $(findstring terminal,$(FEATURES)),terminal) SUBSPACE_BUILD_FEATURES="$(FEATURES)" mise run run -- $(ARGS)

capture: ## macOS/Linux screenshots from an isolated fixture build, with the terminal (OUT=dir STEPS='wait:5000;shot:main')
	@test -n "$(OUT)" || { echo "usage: make capture OUT=<dir> [STEPS='...']" >&2; exit 2; }
	MISE_ENV=terminal mise run capture -- "$(OUT)" '$(STEPS)'

check: ## Architecture, format check, lint, Rust tests and script fixtures
	mise run check

check-terminal: ## Check the excluded Terminal crates with Zig enabled
	MISE_ENV=terminal mise run check-terminal

format: ## Format the Rust sources
	mise run fmt

fmt-check: ## Check the formatting
	mise run fmt-check

lint: ## Run cargo-shear and clippy with warnings denied
	mise run lint

.PHONY: quality quality-baseline audit
quality: ## Fail when the rustqual score drops below the baseline
	mise run quality

quality-baseline: ## Save the current rustqual results as the baseline
	mise run quality-baseline

audit: ## Check the three lockfiles against the RustSec advisory database (network)
	mise run audit

package: ## Build a release archive in dist/ (TARGET=<rust target> VERSION=<x.y.z>)
	mise run package -- "$(TARGET)" "$(VERSION)"

package-macos: ## Build the signed, notarized macOS app ([SIGNING_IDENTITY=...] [KEYCHAIN_PROFILE=...] [TARGET=...])
	@test -n "$(SIGNING_IDENTITY)" || { echo 'SIGNING_IDENTITY is required, for example SIGNING_IDENTITY="Developer ID Application: Name (TEAMID)"' >&2; exit 2; }
	@test -n "$(KEYCHAIN_PROFILE)" || { echo 'KEYCHAIN_PROFILE is required: the notarytool Keychain profile name' >&2; exit 2; }
	mise run package-macos -- "$(SIGNING_IDENTITY)" "$(KEYCHAIN_PROFILE)" $(if $(TARGET),"$(TARGET)")

release-macos: ## On a release tag: build, sign and notarize the app, attach it to the draft release and publish it ([SIGNING_IDENTITY=...] [KEYCHAIN_PROFILE=...] [DRAFT=1])
	@test -n "$(SIGNING_IDENTITY)" || { echo 'SIGNING_IDENTITY is required, for example SIGNING_IDENTITY="Developer ID Application: Name (TEAMID)"' >&2; exit 2; }
	@test -n "$(KEYCHAIN_PROFILE)" || { echo 'KEYCHAIN_PROFILE is required: the notarytool Keychain profile name' >&2; exit 2; }
	RELEASE_DRAFT="$(DRAFT)" mise run release-macos -- "$(SIGNING_IDENTITY)" "$(KEYCHAIN_PROFILE)"

.PHONY: release-macos-prerelease
release-macos-prerelease: ## Cut a download-only integration pre-release from this clean branch (macOS)
	@test -n "$(SIGNING_IDENTITY)" || { echo 'SIGNING_IDENTITY is required, for example SIGNING_IDENTITY="Developer ID Application: Name (TEAMID)"' >&2; exit 2; }
	@test -n "$(KEYCHAIN_PROFILE)" || { echo 'KEYCHAIN_PROFILE is required: the notarytool Keychain profile name' >&2; exit 2; }
	RELEASE_DRAFT="$(DRAFT)" mise run release-macos -- --prerelease "$(SIGNING_IDENTITY)" "$(KEYCHAIN_PROFILE)"

package-macos-ci: ## Build a signed release app from CI secrets, reading missing ones from Key Vault (TARGET=... VERSION=...)
	mise run package-macos-ci -- "$(TARGET)" "$(VERSION)"

.PHONY: sign-windows
sign-windows: ## Sign Windows files or release ZIPs with Azure Artifact Signing (FILES="dist/*.zip"; needs jsign and az)
	@test -n "$(FILES)" || { echo 'usage: make sign-windows FILES="<file.exe|file.dll|file.msi|archive.zip> ..."' >&2; exit 2; }
	bash scripts/sign-windows.sh $(FILES)

install-macos: FEATURES = terminal
install-macos: ## Build and install the app with the terminal (FEATURES= without it, TARGET=...)
	MISE_ENV=$(if $(findstring terminal,$(FEATURES)),terminal) SUBSPACE_BUILD_FEATURES="$(FEATURES)" mise run install-macos -- $(if $(TARGET),"$(TARGET)")

generate-icons: ## Generate native application icons from the canonical SVG
	mise exec -- bash scripts/generate-icons.sh

check-icons: ## Check generated application icon signatures and sizes
	mise exec -- bash scripts/check-icons.sh

cache-stats: ## Show Mr Boxington cache results for the last build
	mise run cache-stats

clean: ## Remove build output
	mise run clean
