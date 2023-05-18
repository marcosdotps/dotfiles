#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

cwd=$(cd "$(dirname "$0")" && pwd)

setup-nvim() {
    echo "==> Setting up neovim"
    curl -LO https://github.com/neovim/neovim/releases/download/v0.8.2/nvim-linux64.deb
    sudo apt install ./nvim-linux64.deb

    rm -rf "$HOME/.config"
    mkdir "$HOME/.config"
    
    rm -rf "$HOME/.config/nvim"
    mkdir "$HOME/.config/nvim"
    ln -s "$cwd/init.vim" "$HOME/.config/nvim/init.vim"
    rm -rf ./nvim-linux64.deb
    nvim --headless +PlugInstall +qa
    echo "==> Finished setting up neovim"
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
    setup-nvim
    echo "==> Successfully finished setting up env"
}

main "$@"
