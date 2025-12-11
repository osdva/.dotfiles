function udot
    set -l original_dir $PWD
    cd ~/.dotfiles && stow -D . && stow .
    cd $original_dir
end
