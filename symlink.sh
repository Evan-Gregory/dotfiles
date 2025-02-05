#!/usr/bin/env bash

# Script to create symlinks to all dotfiles

echo "===== Symlinking dotfiles ====="
DOTFILES="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"
BIN_DIR="$HOME/.local/bin"

create_symlink() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    trash  "$dest"
  fi
  ln -sf "${DOTFILES}/${src}" "${dest}"
}

# create_symlink "justfile" "$HOME/justfile"
create_symlink symlink.sh "$BIN_DIR/.f"

create_symlink nvim "$CONFIG_DIR/nvim"
create_symlink git "$CONFIG_DIR/git"
create_symlink kitty "$CONFIG_DIR/kitty"

# Use sudo directly for system-wide symlink
if [ -e "/etc/keyd/default.conf" ] || [ -L "/etc/keyd/default.conf" ]; then
  sudo trash "/etc/keyd/default.conf"
fi
sudo ln -sf "$DOTFILES/keyd/default.conf" /etc/keyd/default.conf

echo "===== Finished symlinking to dotfiles ====="
