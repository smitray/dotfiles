# Basic completion styles
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Format descriptions and messages
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'


# Basic fzf-tab configuration
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --multi --marker="*"
zstyle ':fzf-tab:*' continuous-trigger 'ctrl-space'
zstyle ':fzf-tab:*' accept-line enter
zstyle ':fzf-tab:*' prefix ''
zstyle ':fzf-tab:*' single-group color header

# Directory preview
if (( $+commands[exa] )); then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'exa -1 --color=always $realpath'
else
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'ls -1 --color=always $realpath'
fi

# Git integration
zstyle ':fzf-tab:complete:git:*' fzf-preview \
'case "$group" in
    "files") git diff --color=always $realpath;;
    "branches") git log --color=always --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $word;;
    *) git status --short;;
esac'

# Command and parameter preview
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
    fzf-preview 'echo ${(P)word}'

# File preview
zstyle ':fzf-tab:complete:*:*' fzf-preview \
    'bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || ls -1 --color=always $realpath'

# Process preview
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
    '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags '--preview-window=down:3:wrap'

# Systemctl preview
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# General completion settings
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:git-checkout:*' sort false

# Switch groups using , and .
zstyle ':fzf-tab:*' switch-group ',' '.'