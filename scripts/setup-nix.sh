#!/usr/bin/env bash

set -euo pipefail

echo "🔍 Checking Nix status..."

# Known install locations, since a fresh shell may not have Nix on PATH
# even when it's already installed (containers don't source shell
# profiles for non-interactive/non-login shells).
NIX_BIN_CANDIDATES=(
    "/nix/var/nix/profiles/default/bin"
    "/nix/var/nix/profiles/per-user/root/profile/bin"
    "$HOME/.nix-profile/bin"
)

find_nix_bin_dir() {
    for dir in "${NIX_BIN_CANDIDATES[@]}"; do
        if [ -x "$dir/nix" ]; then
            echo "$dir"
            return 0
        fi
    done
    return 1
}

if NIX_BIN_DIR=$(find_nix_bin_dir); then
    echo "  ✓ Nix is already installed at $NIX_BIN_DIR"
else
    echo "⚡ Nix not found. Starting official installation..."

    # Single-user install: this is a container with no systemd/init
    # service manager, so --daemon mode's nix-daemon service would never
    # actually start. Single-user mode works directly as root and needs
    # no background service.
    curl --proto '=https' --tlsv1.2 -sSf -L https://nixos.org/nix/install | sh -s -- --no-daemon

    NIX_BIN_DIR=$(find_nix_bin_dir) || {
        echo "❌ Nix installation finished but no nix binary was found in the expected locations." >&2
        exit 1
    }
    echo "  ✓ Nix installed successfully!"
fi

# Make nix commands available in *this* script...
export PATH="$NIX_BIN_DIR:$PATH"

# ...and in every future shell, including non-interactive ones (e.g. tool
# invocations), which skip ~/.bashrc entirely. Symlinking into /usr/local/bin
# is the one PATH fix that survives regardless of shell startup semantics.
echo "🔗 Linking Nix binaries into /usr/local/bin for persistent PATH access..."
for bin in "$NIX_BIN_DIR"/*; do
    ln -sf "$bin" "/usr/local/bin/$(basename "$bin")"
done

# Enable modern Nix Flakes feature by default
echo "⚙️  Configuring experimental features (nix-command flakes)..."
mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
    echo "  ✓ Flakes and modern CLI enabled in ~/.config/nix/nix.conf"
fi

# NOTE: deliberately NOT touching NIX_SSL_CERT_FILE here. This environment
# routes all HTTPS through a proxy with its own CA bundle and already sets
# NIX_SSL_CERT_FILE to the correct proxy-aware bundle. Overriding it with
# the plain system CA bundle breaks TLS verification for every fetch that
# goes through the proxy (i.e. everything).

# Quick functional test
echo ""
echo "✨ Verification:"
nix --version
echo "🚀 Ready! You can now use nix commands (e.g., 'nix flake check')."
