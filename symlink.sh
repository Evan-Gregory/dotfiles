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
echo $HOME
create_symlink symlink.sh "$BIN_DIR/.f"
create_symlink nvim "$CONFIG_DIR/nvim"
create_symlink git "$CONFIG_DIR/git"
create_symlink kitty "$CONFIG_DIR/kitty"
create_symlink hypr "$CONFIG_DIR/hypr"
create_symlink dunst "$CONFIG_DIR/dunst"
create_symlink cava "$CONFIG_DIR/cava"
create_symlink fish "$CONFIG_DIR/fish"
create_symlink wofi "$CONFIG_DIR/wofi"
create_symlink btop "$CONFIG_DIR/btop"
create_symlink starship.toml "$CONFIG_DIR/starship.toml"
create_symlink tmux "$CONFIG_DIR/tmux"
create_symlink lazygit "$CONFIG_DIR/lazygit"
create_symlink nushell "$CONFIG_DIR/nushell"

# TODO: standatdize this 
if [ -e "$HOME/Documents/swww/target/release/swww" ] || [ -L "$HOME/Documents/swww/target/release/swww" ]; then
  trash "$HOME/Documents/swww/target/release/swww"
fi
if [ -e "$HOME/Documents/swww/target/release/swww-daemon" ] || [ -L "$HOME/Documents/swww/target/release/swww-daemon" ]; then
  trash "$HOME/Documents/swww/target/release/swww-daemon"
fi
ln -sf /home/evang/Documents/swww/target/release/swww ~/.local/bin/swww
ln -sf /home/evang/Documents/swww/target/release/swww-daemon ~/.local/bin/swww-daemon


# Use sudo directly for system-wide symlink
if [ -e "/etc/keyd/default.conf" ] || [ -L "/etc/keyd/default.conf" ]; then
  sudo trash "/etc/keyd/default.conf"
fi
sudo ln -sf "$DOTFILES/keyd/default.conf" /etc/keyd/default.conf

if [ -e "/etc/tmux.conf" ] || [ -L "/etc/tmux.conf" ]; then
  sudo trash "/etc/tmux.conf"
fi
sudo ln -sf "$DOTFILES/tmux/tmux.conf" /etc/tmux.conf
sudo ln -df "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf" 

if [ -e "/etc/greetd/config.toml" ] || [ -L "/etc/greetd/config.toml" ]; then
  sudo trash "/etc/greetd/config.toml"
fi
sudo ln -sf "$DOTFILES/greetd/config.toml" /etc/greetd

echo "===== Finished symlinking to dotfiles ====="
