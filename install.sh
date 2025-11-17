#!/usr/bin/env bash
set -euo pipefail

# Directory where this script lives (your dotfiles repo)
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_nvim() {
  echo "==> Installing Neovim v0.11.5"

  # Remove distro neovim if present (ignore errors)
  sudo apt-get update -y
  sudo apt-get remove -y neovim || true

  NVIM_VERSION="v0.11.5"
  NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  echo "Downloading $NVIM_URL"
  curl -fsSL "$NVIM_URL" -o "$tmpdir/nvim-linux-x86_64.tar.gz"

  echo "Extracting Neovim"
  tar -C "$tmpdir" -xzf "$tmpdir/nvim-linux-x86_64.tar.gz"

  # The archive unpacks to a directory named nvim-linux-x86_64
  if [ ! -d "$tmpdir/nvim-linux-x86_64" ]; then
    echo "Error: expected directory $tmpdir/nvim-linux-x86_64 not found after extraction" >&2
    exit 1
  fi

  # Install under /usr/local/nvim
  sudo rm -rf /usr/local/nvim
  sudo mv "$tmpdir/nvim-linux-x86_64" /usr/local/nvim

  # Symlink /usr/bin/nvim -> /usr/local/nvim/bin/nvim
  sudo rm -f /usr/bin/nvim
  sudo ln -s /usr/local/nvim/bin/nvim /usr/bin/nvim

  echo "Neovim installed at /usr/local/nvim/bin/nvim"
  nvim --version | head -3 || true
}

setup_config() {
  echo "==> Setting up Neovim config from $script_dir/nvim"

  mkdir -p "$HOME/.config"

  # Backup any existing config
  if [ -d "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
  fi

  # Copy your nvim directory as-is
  cp -r "$script_dir/nvim" "$HOME/.config/nvim"

  # Remove git metadata if present
  rm -rf "$HOME/.config/nvim/.git" || true

  echo "Config set at $HOME/.config/nvim"
}

main() {
  install_nvim
  setup_config
  echo "==> Done."
}

main "$@"
