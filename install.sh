#!/usr/bin/env bash

set -o pipefail
set -o errexit
set -o nounset

cwd="/workspaces/.codespaces/.persistedshare/dotfiles"

setup-lvim() {
    echo "==> Patching pip error..."
    rm -f ~/.config/pip/pip.conf
    mkdir -p ~/.config/pip/
    touch ~/.config/pip/pip.conf
    echo "[global]" >  ~/.config/pip/pip.conf
    echo "break-system-packages = true" >> ~/.config/pip/pip.conf
    echo "user = true" >> ~/.config/pip/pip.conf
    echo "==> Setting up lunarvim"
    bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh) -y
    rm -rf "$HOME/.config/lvim"
    mkdir -p "$HOME/.config/lvim"
    cp "$cwd/config.lua" "$HOME/.config/lvim/config.lua"
    cp "$cwd/lazy-lock.json" "$HOME/.config/lvim/lazy-lock.json"
    echo "==> Finished setting up LunarVim"
}

apt-install() {
    echo "==> Start apt-installing packages"
    sudo apt update

   # Preconfigure the locale settings to avoid interactive prompts
    sudo locale-gen en_US.UTF-8
    echo 'LANG="en_US.UTF-8"' | sudo tee /etc/default/locale
    echo 'LANGUAGE="en_US:en"' | sudo tee -a /etc/default/locale
    echo 'LC_ALL="en_US.UTF-8"' | sudo tee -a /etc/default/locale

    # Apply the locale settings
    sudo update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

    # Export locale variables for the current session
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US:en
    export LC_ALL=en_US.UTF-8


    # Installing dependencies
    sudo apt install -y exuberant-ctags bat tree shellcheck icdiff autojump jq ripgrep libevent-dev ncurses-dev build-essential bison pkg-config python3-pynvim


    # Add neovim v0.10 from repo
    sudo apt remove -y neovim
    curl -LO https://github.com/neovim/neovim/releases/download/v0.10.0/nvim-linux64.tar.gz

    # Check if the download was successful
    if [ $? -ne 0 ]; then
        echo "Failed to download nvim-linux64.tar.gz"
        exit 1
    fi

    # Extract the tar.gz file
    tar xzvf nvim-linux64.tar.gz

    # Check if extraction was successful
    if [ $? -ne 0 ]; then
        echo "Failed to extract nvim-linux64.tar.gz"
        exit 1
    fi

    # Ensure the current directory contains the extracted files
    if [ ! -d "$(pwd)/nvim-linux64" ]; then
        echo "nvim-linux64 directory not found"
        exit 1
    fi

    # Remove existing nvim symlink or file
    sudo rm -f /usr/bin/nvim

    # Create a new symlink
    sudo ln -s $cwd/nvim-linux64/bin/nvim /usr/bin/nvim

    # Verify the symlink creation
    if [ -L /usr/bin/nvim ]; then
        echo "Successfully updated nvim symlink"
    else
        echo "Failed to create nvim symlink"
        exit 1
    fi

    # Installing rust... why not!? (someone needs to explain this to me)
    sh <(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs) -y
    source $HOME/.cargo/env
    echo "==> Finished apt-installing packages"
}

main() {
    if [[ "$#" -gt 0 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
        usage
    fi

    echo "==> Starting to set up env"
    apt-install
    setup-lvim
    echo "export PATH=\"\$PATH:/home/codespace/.local/bin/lvim\"" >> ~/.bashrc
    echo "==> Successfully finished setting up env"
}

echo "==> Starting setup script"

# Track time taken to run the main function
time main "$@"

