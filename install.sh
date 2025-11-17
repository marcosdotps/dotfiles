#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

# Base directory for this dotfiles repo (directory containing install.sh)
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cwd="$script_dir"

setup-nvim() {
  echo "==> Setting up neovim config"

  mkdir -p "$HOME/.config"

  # Backup existing config if present
  if [ -d "$HOME/.config/nvim" ]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
  fi

  # Copy nvim config from dotfiles repo
  # Use -r to copy directory contents, not just the directory node
  cp -r "$cwd/nvim" "$HOME/.config/nvim"

  # Remove any git metadata from the copied config
  rm -rf "$HOME/.config/nvim/.git" || true

  echo "==> Finished setting up neovim config"
}

apt-install() {
  echo "==> Start apt-installing packages"
  sudo apt update

  # Preconfigure the locale settings to avoid interactive prompts
  sudo locale-gen en_US.UTF-8
  {
    echo 'LANG="en_US.UTF-8"'
    echo 'LANGUAGE="en_US:en"'
    echo 'LC_ALL="en_US.UTF-8"'
  } | sudo tee /etc/default/locale >/dev/null

  # Apply the locale settings
  sudo update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

  # Export locale variables for the current session
  export LANG=en_US.UTF-8
  export LANGUAGE=en_US:en
  export LC_ALL=en_US.UTF-8

  # Installing dependencies
  sudo apt install -y \
    exuberant-ctags \
    bat \
    tree \
    shellcheck \
    icdiff \
    autojump \
    jq \
    ripgrep \
    libevent-dev \
    ncurses-dev \
    build-essential \
    bison \
    pkg-config \
    python3-pynvim \
    xclip

  # Install Neovim from official release tarball
  echo "==> Installing Neovim from official release"
  sudo apt remove -y neovim || true

  NVIM_VERSION="v0.11.1"
  NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz"

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  echo "Downloading Neovim from ${NVIM_URL}"
  # -f: fail on HTTP errors, -S: show errors, -L: follow redirects, -s: silent
  if ! curl -fsSL "$NVIM_URL" -o "$tmpdir/nvim-linux64.tar.gz"; then
    echo "Error: failed to download Neovim tarball from $NVIM_URL" >&2
    exit 1
  fi

  # Optional: sanity check that we got a gzip file
  if ! file "$tmpdir/nvim-linux64.tar.gz" | grep -q 'gzip compressed data'; then
    echo "Error: downloaded Neovim tarball is not a gzip archive. Contents:" >&2
    head -c 256 "$tmpdir/nvim-linux64.tar.gz" || true
    exit 1
  fi

  echo "Extracting Neovim tarball"
  tar -C "$tmpdir" -xzf "$tmpdir/nvim-linux64.tar.gz"

  if [ ! -d "$tmpdir/nvim-linux64" ]; then
    echo "Error: nvim-linux64 directory not found after extraction" >&2
    exit 1
  fi

  # Install into /usr/local/nvim and update symlink
  sudo rm -rf /usr/local/nvim
  sudo mkdir -p /usr/local
  sudo mv "$tmpdir/nvim-linux64" /usr/local/nvim

  sudo rm -f /usr/bin/nvim
  sudo ln -s /usr/local/nvim/bin/nvim /usr/bin/nvim

  if [ -L /usr/bin/nvim ]; then
    echo "Successfully installed Neovim and updated /usr/bin/nvim symlink"
  else
    echo "Failed to create /usr/bin/nvim symlink" >&2
    exit 1
  fi

  # Installing rust
  echo "==> Installing Rust via rustup"
  if ! command -v rustc >/dev/null 2>&1; then
    sh <(curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs) -y
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
  fi

  echo "==> Finished apt-installing packages"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -h, --help    Show this help message.
EOF
}

main() {
  if [[ "$#" -gt 0 && ("$1" == "-h" || "$1" == "--help") ]]; then
    usage
    exit 0
  fi

  echo "==> Starting to set up env"
  apt-install
  setup-nvim
  echo "==> Successfully finished setting up env"
}

echo "==> Starting setup script"

# Track time taken to run the main function
time main "$@"
