#!/bin/bash
# Bootstrap only: oh-my-zsh and its plugins are updated by omz itself afterwards.
set -euo pipefail

ZSH_DIR="$HOME/.oh-my-zsh"
PLUGINS="$ZSH_DIR/custom/plugins"

clone() { # <url> <target>
  [ -d "$2" ] || git clone --depth=1 "$1" "$2"
}

command -v git >/dev/null || { echo "git not found, skipping oh-my-zsh" >&2; exit 0; }

clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH_DIR"
clone https://github.com/zsh-users/zsh-autosuggestions.git "$PLUGINS/zsh-autosuggestions"
clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGINS/zsh-syntax-highlighting"
