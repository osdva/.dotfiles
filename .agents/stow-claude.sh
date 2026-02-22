#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
AGENTS_DIR="$DOTFILES_DIR/.agents"
CLAUDE_DIR="$DOTFILES_DIR/.claude"

mkdir -p "$CLAUDE_DIR/skills"
stow --dir "$AGENTS_DIR" --target "$CLAUDE_DIR/skills" -R -v skills
