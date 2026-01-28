# Sets
set -g fish_greeting
set --global fish_key_bindings fish_default_key_bindings

# fzf
fzf_configure_bindings --directory=\cf --git_status=\cs --processes=\cp
set fzf_diff_highlighter delta --paging=never --width=20
set fzf_fd_opts --hidden --max-depth 5
set -x FZF_DEFAULT_OPTS_FILE ~/.config/fzf/fzf.conf

# Host-specific exports
set -l host_name (cat /etc/hostname 2>/dev/null | string trim || echo "unknown")
set host_rc $HOME/.dotfiles/hosts/$host_name/fish.local.fish
set host_secrets $HOME/.dotfiles/hosts/$host_name/secrets.fish
if test -f "$host_rc"
    source "$host_rc"
end
if test -f "$host_secrets"
    source "$host_secrets"
end

mise activate fish | source
zoxide init fish | source
op completion fish | source
eval (tmuxifier init - fish)
starship init fish | source
