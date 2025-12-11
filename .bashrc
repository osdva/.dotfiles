export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export SSH_AUTH_SOCK=~/.1password/agent.sock
export FZF_DEFAULT_OPTS_FILE="$HOME/.config/fzf/fzf.conf"
export PATH="$HOME/.config/tmux/plugins/tmuxifier/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/mise/shims:$PATH"

if [[ $- == *i* ]] && [[ -z "$FISH_VERSION" ]]; then
  exec fish
fi
