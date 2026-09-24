# Options inherited by the interactive fish session.
export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export SSH_AUTH_SOCK="$HOME/.ssh/proton-pass-ssh-agent.sock"
export PATH="$HOME/.config/tmux/plugins/tmuxifier/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Login shell stays zsh. A real terminal session switches to fish.
# Cursor's agent starts an interactive zsh on a PTY and then sends the
# command. `exec fish` there drops the command and the session sits at a prompt.
_parent_comm=$(ps -p $PPID -o comm= 2>/dev/null || true)
_zsh_args=$(ps -p $$ -o args= 2>/dev/null || true)
_human_terminal=0
case "$_parent_comm" in
  *login*|*sshd*|*Terminal*|*iTerm*|*ghostty*|*kitty*|*WezTerm*|*alacritty*|*Warp*)
    _human_terminal=1
    ;;
esac
_running_command=0
if [[ "$_zsh_args" =~ '(^|[[:space:]])-[A-Za-z]*c' ]]; then
  _running_command=1
fi

if [[ "$_human_terminal" == 1 && "$_running_command" == 0 && $- == *i* && -t 1 && -z "$FISH_VERSION" ]] && command -v fish >/dev/null 2>&1; then
  exec fish
fi

# Agent and `zsh -ic` shells never reach a person. Skip plugin init below;
# compinit can wait forever for a confirmation prompt on a PTY.
if [[ "$_human_terminal" == 0 || "$_running_command" == 1 ]]; then
  return
fi

# Init plugin manager: znit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Snippets
zinit snippet OMZP::git
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# History
HISTSIZE=100000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Bindings
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# Aliases
alias cat="bat"
alias ls="eza --color --icons --git -a"
alias vim="nvim"
alias lzg="lazygit"
alias g="gitu"
alias lzd="lazydocker" 
alias wf="impala"
alias bt="bluetui"
alias spt="spotify_player"
alias dot="(cd ~/.dotfiles && nvim)"
alias udot="(cd ~/.dotfiles && stow -D . && stow .)"
alias sr="source ~/.zshrc"

# Functions
function br {
    local cmd cmd_file code
    cmd_file=$(mktemp)
    if broot --outcmd "$cmd_file" "$@"; then
        cmd=$(<"$cmd_file")
        command rm -f "$cmd_file"
        eval "$cmd"
    else
        code=$?
        command rm -f "$cmd_file"
        return "$code"
    fi
}

function cd {
  z "$@" && eza --color --icons --git -a
}

# Completion style
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --color --icons --git -a $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color --icons --git -a $realpath'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza --color --icons --git -a $realpath'
zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza --color --icons --git -a $realpath'

# Shell integrations
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/theme.omp.json)"
eval "$(fzf --zsh)"
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
eval "$(tmuxifier init -)"
