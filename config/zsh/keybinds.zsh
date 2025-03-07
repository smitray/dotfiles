# =============================================================================
# ZSH KEYBINDINGS CONFIGURATION
# =============================================================================

# ===== VI MODE CONFIGURATION =====
bindkey -v                   # Enable vi mode
export KEYTIMEOUT=1          # Reduce delay when switching modes

# ===== MODULE AND FUNCTION LOADING =====
# Load required modules
autoload -U edit-command-line
autoload -Uz compinit && compinit
autoload -U url-quote-magic
autoload -Uz bracketed-paste-magic

# Widget declarations
zle -N edit-command-line
zle -N zle-keymap-select
zle -N zle-line-init
zle -N fancy-ctrl-z
zle -N expand-or-complete-with-dots
zle -N fh
zle -N fzf-history-widget
zle -N rationalise-dot
zle -N self-insert url-quote-magic      # URL escape handling
zle -N bracketed-paste bracketed-paste-magic

# ===== CURSOR SHAPE MANAGEMENT =====
function zle-keymap-select() {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'    # Block cursor for normal mode
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || \
         [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
        echo -ne '\e[5 q'    # Beam cursor for insert mode
    fi
}

function zle-line-init() {
    echo -ne '\e[5 q'        # Beam cursor on line init
}

# Initialize cursor shape
echo -ne '\e[5 q'            # Ensure beam cursor on startup

# ===== COMPLETION MENU NAVIGATION =====
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect '^xg' clear-screen
bindkey -M menuselect '^xi' vi-insert                   # Insert
bindkey -M menuselect '^xh' accept-and-hold             # Hold
bindkey -M menuselect '^xn' accept-and-infer-next-history
bindkey -M menuselect '^xu' undo                        # Undo
bindkey -M menuselect '\e' send-break                   # Exit menu with ESC

# ===== HISTORY NAVIGATION =====
# History search bindings
bindkey '^[[A' history-substring-search-up              # Up arrow
bindkey '^[[B' history-substring-search-down            # Down arrow
bindkey "$terminfo[kcuu1]" history-substring-search-up  # Up arrow (terminal independent)
bindkey "$terminfo[kcud1]" history-substring-search-down # Down arrow (terminal independent)
bindkey -M vicmd 'k' history-substring-search-up        # Vi normal mode up
bindkey -M vicmd 'j' history-substring-search-down      # Vi normal mode down
bindkey '^R' fzf-history-widget                         # Fuzzy history search

# ===== COMMAND EDITING =====
bindkey -M vicmd 'v' edit-command-line                  # Normal mode: press v
bindkey -M viins '^e' edit-command-line                 # Insert mode: ctrl-e
bindkey '^[.' insert-last-word                          # Alt+. insert last word
bindkey '^U' backward-kill-line                         # Ctrl+U clear line
bindkey '^[q' push-line-or-edit                         # Alt+Q push line to stack
bindkey ' ' magic-space                                 # History expansion on space

# Completion with dots
expand-or-complete-with-dots() {
    print -Pn "%F{red}...%f"
    zle expand-or-complete
    zle redisplay
}
bindkey "^I" expand-or-complete-with-dots              # Show dots during completion

# ===== DIRECTORY NAVIGATION =====
bindkey '^[^[[D' backward-word                         # Alt+Left: back one word
bindkey '^[^[[C' forward-word                          # Alt+Right: forward one word
bindkey '^[[1;5D' backward-word                        # Ctrl+Left: back one word
bindkey '^[[1;5C' forward-word                         # Ctrl+Right: forward one word

# Quick directory switching
fancy-ctrl-z() {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line -w
    else
        zle push-input -w
        zle clear-screen -w
    fi
}
bindkey '^Z' fancy-ctrl-z                              # Ctrl+Z toggle background

# ===== FUZZY FINDER INTEGRATION =====
# Function to search history using fzf
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | \
      fzf +s --tac | \
      sed -E 's/ *[0-9]*\*? *//' | \
      sed -E 's/\\/\\\\/g')
}

# Enhanced fzf history widget
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
bindkey -M viins '^[h' fh
bindkey -M vicmd '^[h' fh

# ===== FILE NAVIGATION =====
# Rationalize dot command (... -> ../..)
rationalise-dot() {
    if [[ $LBUFFER = *.. ]]; then
        LBUFFER+=/..
    else
        LBUFFER+=.
    fi
}
zle -N rationalise-dot
bindkey . rationalise-dot                              # Type ... to cd ../..

# ===== CUSTOM SHORTCUTS ===== 
# Note: These have potential conflicts with tmux Alt bindings
bindkey -s '^o' 'lfcd\n'                              # Ctrl+O triggers lfcd
bindkey -s '^[s' 'server_manager\n'                   # Alt+S triggers server_manager
bindkey -s '^[g' 'live_grep\n'                        # Alt+G triggers live_grep
bindkey -s '^[q' 'quick_find\n'                       # Alt+Q triggers quick_find
bindkey -s '^[r' 'nvim_recent\n'                      # Alt+R triggers nvim_recent
bindkey -s '^[f' 'zoxide_find\n'                      # Alt+F triggers zoxide_find
bindkey -s '^[c' 'clipboard_history\n'                # Alt+c triggers clipboard_history