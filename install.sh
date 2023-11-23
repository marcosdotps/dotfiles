#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

cwd=$(cd "$(dirname "$0")" && pwd)

setup-lvim() {
    echo "==> Setting up neovim"
    LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)
    rm -rf "$HOME/.config/lvim"
    mkdir -p "$HOME/.config/lvim"
    cp "$cwd/config.lua" "$HOME/.config/lvim/config.lua"
    cp "$cwd/lazy-lock.json" "$HOME/.config/lvim/lazy-lock.json"
    echo "==> Finished setting up LunarVim"
}

apt-install() {
    echo "==> Start apt-installing packages"
    sudo apt update
    sudo apt install -y exuberant-ctags bat tree shellcheck icdiff autojump jq ripgrep libevent-dev ncurses-dev build-essential bison pkg-config
    sudo locale-gen en_US.UTF-8
    sudo dpkg-reconfigure locales
    echo "==> Finished apt-installing packages"
}

main() {
    if [[ "$#" -gt 0 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
        usage
    fi

    echo "==> Starting to set up env"
    apt-install
    setup-lvim
    echo "==> Successfully finished setting up env"
}

main "$@"
