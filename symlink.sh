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
create_symlink hypr/.icons "$HOME"
create_symlink dunst "$CONFIG_DIR/dunst"
create_symlink cava "$CONFIG_DIR/cava"
create_symlink fish "$CONFIG_DIR/fish"
create_symlink wofi "$CONFIG_DIR/wofi"
create_symlink btop "$CONFIG_DIR/btop"
create_symlink starship.toml "$CONFIG_DIR/starship.toml"
# create_symlink tmux "$HOME/.tmux.conf"
create_symlink lazygit "$CONFIG_DIR/lazygit"
create_symlink nushell "$CONFIG_DIR/nushell"
create_symlink quickshell "$CONFIG_DIR/quickshell"
create_symlink yazi "$CONFIG_DIR/yazi"
create_symlink hyprshell "$CONFIG_DIR/hyprshell"
create_symlink flameshot "$CONFIG_DIR/flameshot"

# TODO: standatdize this 
if [ -e "$HOME/Documents/awww/target/release/awww" ] || [ -L "$HOME/Documents/awww/target/release/awww" ]; then
  trash "$HOME/Documents/awww/target/release/awww"
fi
if [ -e "$HOME/Documents/awww/target/release/awww-daemon" ] || [ -L "$HOME/Documents/awww/target/release/awww-daemon" ]; then
  trash "$HOME/Documents/awww/target/release/awww-daemon"
fi
ln -sf /home/evang/Documents/awww/target/release/awww ~/.local/bin/awww
ln -sf /home/evang/Documents/awww/target/release/awww-daemon ~/.local/bin/awww-daemon


# Use sudo directly for system-wide symlink
if [ -e "/etc/keyd/default.conf" ] || [ -L "/etc/keyd/default.conf" ]; then
  sudo trash "/etc/keyd/default.conf"
fi
sudo ln -sf "$DOTFILES/keyd/default.conf" /etc/keyd/default.conf

if [ -e "/etc/tmux.conf" ] || [ -L "/etc/tmux.conf" ]; then
  sudo trash "/etc/tmux.conf"
fi
sudo ln -sf "$DOTFILES/tmux/tmux.conf" /etc/tmux.conf
sudo ln -sf "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf" 

if [ -e "/etc/greetd/config.toml" ] || [ -L "/etc/greetd/config.toml" ]; then
  sudo trash "/etc/greetd/config.toml"
fi
sudo ln -sf "$DOTFILES/greetd/config.toml" /etc/greetd

echo "===== Finished symlinking to dotfiles ====="
