#!/usr/bin/env bash
set -euo pipefail

# Directory where this script lives (your dotfiles repo)
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
  setup_config
  echo "==> Done."
}

main "$@"
