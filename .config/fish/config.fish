# Sets
set -g fish_greeting

# fzf
fzf_configure_bindings --directory=\cf --git_status=\cs --processes=\cp
set fzf_diff_highlighter delta --paging=never --width=20
set fzf_fd_opts --hidden --max-depth 5
set -x FZF_DEFAULT_OPTS_FILE ~/.config/fzf/fzf.conf

mise activate fish | source
zoxide init fish | source
op completion fish | source
eval (tmuxifier init - fish)
starship init fish | source
