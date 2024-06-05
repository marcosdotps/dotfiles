#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

cwd="/workspaces/.codespaces/.persistedshare/dotfiles"

setup-lvim() {
    echo "==> Setting up neovim"
    bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh) -y
    rm -rf "$HOME/.config/lvim"
    mkdir -p "$HOME/.config/lvim"
    cp "$cwd/config.lua" "$HOME/.config/lvim/config.lua"
    cp "$cwd/lazy-lock.json" "$HOME/.config/lvim/lazy-lock.json"
    echo "==> Finished setting up LunarVim"
}

apt-install() {
    echo "==> Start apt-installing packages"
    apt update
   
   # Preconfigure the locale settings to avoid interactive prompts
    locale-gen en_US.UTF-8
    echo 'LANG="en_US.UTF-8"' | sudo tee /etc/default/locale
    echo 'LANGUAGE="en_US:en"' | sudo tee -a /etc/default/locale
    echo 'LC_ALL="en_US.UTF-8"' | sudo tee -a /etc/default/locale

    # Apply the locale settings
    sudo update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

    # Export locale variables for the current session
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US:en
    export LC_ALL=en_US.UTF-8

    export LANG=en_US.UTF-8
    export LANGUAGE=en_US
    export LC_ALL=en_US.UTF-8
    sudo apt install -y exuberant-ctags bat tree shellcheck icdiff autojump jq ripgrep libevent-dev ncurses-dev build-essential bison pkg-config
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
