#!/bin/bash

function install_dev_tools() {
  brew upgrade

  echo "installing wezterm and neovim"
  brew install --cask wezterm

  echo "installing cmd tools used by telescope plugin in nvim"
  brew install ripgrep
  brew install fd

  echo "installing lazygit"
  brew install lazygit

  echo "installing jetbrains nerd fonts"
  brew tap homebrew/cask-fonts
  brew install --cask font-jetbrains-mono-nerd-font

  echo "Finished installing dev tools!!"
}

function setup_neovim() {
  echo "configuring nvim"

  # using vanilla LazyVim
  git clone https://github.com/LazyVim/starter ~/.config/nvim
  rm -rf ~/.config/nvim/.git

  # # symbolic link for the config
  # # so that the future git pulls will affect the existing config
  # mkdir -p ~/.config
  # rm -rf ~/.config/nvim
  # ln -s $(pwd)/nvim ~/.config/nvim
}

function setup_wezterm() {
  echo "configuring wezterm"
  ls -s $(pwd)/.wezterm.lua ~/.wezterm.lua
}

install_dev_tools
setup_neovim
setup_wezterm

"Please install neovim yourself! You could install with homebrew et al."
"Or, what I prefer is to download the prebuilt binary from the official site. Put in ~/.local directory and update the PATH in ~/.zshrc with the path to the /bin"
