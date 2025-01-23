# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Load required modules
autoload -U edit-command-line

# Declare and load widgets
zle -N edit-command-line
zle -N fh
zle -N fzf-history-widget

# Use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Better key bindings for command history
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# Edit command in nvim
bindkey -M vicmd 'v' edit-command-line    # Normal mode: press v
bindkey -M viins '^e' edit-command-line   # Insert mode: ctrl-e

# Function to search history using fzf
function fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

function fzf-history-widget() {
    local selected
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
    selected=( $(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
        FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,ctrl-z:ignore ${FZF_CTRL_R_OPTS:-} --query=${(qqq)LBUFFER} +m" fzf) )
    local ret=$?
    if [ -n "$selected" ]; then
        num=$selected[1]
        if [ -n "$num" ]; then
            zle vi-fetch-history -n $num
        fi
    fi
    zle reset-prompt
    return $ret
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget
bindkey -M viins '^[h' fh
bindkey -M vicmd '^[h' fh

# Cursor shape for different vi modes
function zle-keymap-select {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'  # Block cursor for normal mode
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
        echo -ne '\e[5 q'  # Beam cursor for insert mode
    fi
}
zle -N zle-keymap-select

# Ensure beam cursor on zsh startup
echo -ne '\e[5 q'

# Reset cursor style on zle startup/finish
function zle-line-init() {
    echo -ne '\e[5 q'
}
zle -N zle-line-init
