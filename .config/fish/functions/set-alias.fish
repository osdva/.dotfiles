function set-alias --wraps='alias -s' --description 'alias set-alias=alias -s'
    alias -s $argv
end
