function dot
    set -l original_dir $PWD
    cd ~/.dotfiles && nvim $argv
    cd $original_dir
end
