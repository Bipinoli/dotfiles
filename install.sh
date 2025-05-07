#!/bin/bash

function install_dev_tools() {
	brew upgrade

	echo "installing wezterm and neovim"
	brew install --cask wezterm
	brew install neovim

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

	# symbolic link for the config
	# so that the future git pulls will affect the existing config
	mkdir -p ~/.config
	rm -rf ~/.config/nvim
	ln -s $(pwd)/nvim ~/.config/nvim
}

function setup_wezterm() {
	echo "configuring wezterm"
	ls -s $(pwd)/.wezterm.lua ~/.wezterm.lua
}

install_dev_tools
setup_neovim
setup_wezterm
