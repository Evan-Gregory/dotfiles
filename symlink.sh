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
  echo "Symlink created: $dest -> ${DOTFILES}/${src}"
}

# create_symlink "justfile" "$HOME/justfile"
create_symlink symlink.sh "$BIN_DIR/.f"
create_symlink nvim "$CONFIG_DIR/nvim"
create_symlink git "$CONFIG_DIR/git"
create_symlink kitty "$CONFIG_DIR/kitty"
create_symlink hypr "$CONFIG_DIR/hypr"
create_symlink dunst "$CONFIG_DIR/dunst"
create_symlink cava "$CONFIG_DIR/cava"
create_symlink fish "$CONFIG_DIR/fish"
create_symlink wofi "$CONFIG_DIR/wofi"
create_symlink starship.toml "$CONFIG_DIR/starship.toml"

# TODO: standatdize this 
ln -s /home/evang/Documents/swww/target/release/swww ~/.local/bin/swww
ln -s /home/evang/Documents/swww/target/release/swww-daemon ~/.local/bin/swww-daemon


# Use sudo directly for system-wide symlink
if [ -e "/etc/keyd/default.conf" ] || [ -L "/etc/keyd/default.conf" ]; then
  sudo trash "/etc/keyd/default.conf"
fi
sudo ln -sf "$DOTFILES/keyd/default.conf" /etc/keyd/default.conf

echo "===== Finished symlinking to dotfiles ====="
