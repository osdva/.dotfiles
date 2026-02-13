export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export FZF_DEFAULT_OPTS_FILE="$HOME/.config/fzf/fzf.conf"
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
export PATH="$HOME/.config/tmux/plugins/tmuxifier/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Host-specific exports
HOST_NAME=$(cat /etc/hostname 2>/dev/null | tr -d '\n' || echo "unknown")
HOST_RC="$HOME/.dotfiles/hosts/$HOST_NAME/.bashrc.local"
HOST_SECRETS="$HOME/.dotfiles/hosts/$HOST_NAME/.bashrc.secrets"
if [ -f "$HOST_RC" ]; then
  source "$HOST_RC"
fi
if [ -f "$HOST_SECRETS" ]; then
  source "$HOST_SECRETS"
fi

if [ -S ~/.1password/agent.sock ]; then
  export SSH_AUTH_SOCK=~/.1password/agent.sock
fi

if [[ $- == *i* ]] && [[ -z "$FISH_VERSION" ]]; then
  exec fish
fi
