function fish_greeting
    fastfetch -c ~/.config/fastfetch/config2.jsonc
end

function fish_command_not_found
    __fish_default_command_not_found_handler $argv
end

fish_add_path ~/.local/bin
starship init fish | source

alias suspend="systemctl suspend"
alias img=swayimg
alias v='$EDITOR'
alias vcp="vim ~/code/cpp/temp.cpp"
alias nvcp="nvim ~/code/cpp/temp.cpp"
alias pdf=mercury-browser
alias ls='eza -a --icons=always'
alias ll='eza -l --icons=always'
alias ll='eza -al --icons=always'
alias lt='eza -a --tree --level=1 --icons=always'
#alias ls=eza
#alias ll="eza --long"
#alias la="eza --long --all"
alias shutdown='systemctl poweroff'
alias nf='fastfetch'
alias ff='fastfetch'
alias wifi='nmtui'
