# Basic completion styles
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' completer _expand _complete _ignored _approximate

# Format descriptions and messages
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'

# Basic fzf-tab configuration
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --multi --marker="*"
zstyle ':fzf-tab:*' continuous-trigger 'ctrl-space'
zstyle ':fzf-tab:*' accept-line enter
zstyle ':fzf-tab:*' prefix ''
zstyle ':fzf-tab:*' single-group color header

# Directory preview with fallbacks
if (( $+commands[exa] )); then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'exa -1 --color=always $realpath'
elif (( $+commands[tree] )); then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'tree -C $realpath | head -200'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'tree -C $realpath | head -200'
else
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'ls -1 --color=always $realpath'
fi

# Git integration with enhanced previews
zstyle ':fzf-tab:complete:git:*' fzf-preview \
'case "$group" in
    "files") 
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            git diff --color=always $realpath || git diff --staged --color=always $realpath || ls -l --color=always $realpath
        else
            ls -l --color=always $realpath
        fi ;;
    "branches") 
        git log --color=always --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $word ;;
    "tags") 
        git show --color=always $word ;;
    "remotes") 
        git remote -v | grep $word ;;
    *) git status --short ;;
esac'

# Command and parameter preview
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
    fzf-preview 'echo ${(P)word}'

# File preview with enhanced bat configuration
zstyle ':fzf-tab:complete:*:*' fzf-preview \
'if [[ -f $realpath ]]; then
    if file --mime-type $realpath | grep -q "^text/"; then
        bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null
    elif file --mime-type $realpath | grep -q "image/"; then
        echo "Image file: $(file $realpath)"
    else
        file -b $realpath
    fi
elif [[ -d $realpath ]]; then
    exa -1 --color=always $realpath
else
    echo "No preview available"
fi'

# Process preview with enhanced information
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
'[[ $group == "[process ID]" ]] && ps -p $word -o pid,ppid,user,cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags '--preview-window=down:3:wrap'

# Systemctl preview with colors
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# Docker completion previews
zstyle ':fzf-tab:complete:docker:argument-1' fzf-preview \
'case $group in
    "containers") docker ps -a -f "id=$word" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" ;;
    "images") docker images -f "reference=$word" --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}" ;;
    *) echo "No preview available" ;;
esac'

# General completion settings
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,cmd -w -w'
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-order hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order hosts-domain hosts-host hosts-ipaddr

# Switch groups using , and .
zstyle ':fzf-tab:*' switch-group ',' '.'
