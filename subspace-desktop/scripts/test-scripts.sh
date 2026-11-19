#!/usr/bin/env bash
# Run portable release and installer fixtures and the macOS-only bundle fixtures.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
python3 -I "$root/scripts/test-subspace-api-test-server.py"
python3 "$root/scripts/test-github-test-server.py"
python3 "$root/scripts/test-package-web-space.py"
bash "$root/scripts/test-gallery-browser-session.sh"
bash "$root/scripts/test-generate-icons.sh"
bash "$root/scripts/test-product-icon-resources.sh"
bash "$root/scripts/test-prepare-onnx-runtime.sh"
bash "$root/scripts/test-prefetch-zig-deps.sh"
bash "$root/scripts/test-release-signing-allowed.sh"
case "$(uname -s)" in
MINGW* | MSYS* | CYGWIN* | Windows_NT)
	# The release asset check runs only on the Ubuntu publish runner and needs
	# zip and unzip, which Git Bash on Windows runners does not have. The
	# pre-release fixtures start `bash` from native Windows Python, which
	# resolves to WSL there. Planning, publication and retention run on Ubuntu.
	# The version stamp also runs in the Windows build, where a failure stops
	# the run before anything is published.
	echo "release asset and pre-release fixtures skipped on $(uname -s)"
	;;
*)
    python3 "$root/scripts/test-prereleases.py"
    bash "$root/scripts/test-release-assets.sh"
    bash "$root/scripts/test-sign-windows.sh"
    bash "$root/scripts/test-prerelease-products.sh"
    ;;
esac
bash "$root/scripts/test-install-releases.sh"
case "$(uname -s)" in
Darwin | Linux) bash "$root/scripts/test-capture.sh" ;;
esac

if [[ "$(uname -s)" = Darwin ]]; then
	bash "$root/scripts/test-bundle-mise.sh"
	bash "$root/scripts/test-desktop-session.sh"
	bash "$root/scripts/test-package-macos-ci.sh"
	python3 "$root/scripts/test-release-macos-worktree.py"
	bash "$root/scripts/test-run-app.sh"
	bash "$root/scripts/test-package-products.sh"
else
	echo "macOS bundle fixtures skipped on $(uname -s)"
fi
