# Function to show recent files and open with nvim
function recent() {
    # Directory for storing recent files
    local RECENT_FILES_DIR="$XDG_CACHE_HOME/zsh/recent_files"
    local RECENT_FILES_LIST="$RECENT_FILES_DIR/recent.txt"

    # Create directory and file if they don't exist
    [[ ! -d "$RECENT_FILES_DIR" ]] && mkdir -p "$RECENT_FILES_DIR"
    [[ ! -f "$RECENT_FILES_LIST" ]] && touch "$RECENT_FILES_LIST"

    local file
    file=$(rg --files --hidden --no-ignore | \
        fzf --preview 'bat --style=numbers --color=always --line-range=:500 {}' \
            --preview-window 'up,60%,border-bottom,~3' \
            --header 'Recent files' \
            --height '80%' \
            --bind 'ctrl-d:execute(echo {} | xargs -r dirname | cd)' \
            --bind 'ctrl-y:execute-silent(echo {} | clipboard-copy)')
    
    if [[ -n "$file" ]]; then
        echo "$file" >> "$RECENT_FILES_LIST"
        nvim "$file"
    fi
}

# Function to browse folders with fzf
function fb() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git --exclude node_modules | \
        fzf --preview 'exa -T -L 2 {} | head -n 40' \
            --header 'Browse directories' \
            --height '80%' \
            --preview-window 'right:50%' \
            --bind 'ctrl-d:change-preview-window(down|hidden|)' \
            --bind 'ctrl-/:toggle-preview' \
            --bind 'ctrl-y:execute-silent(echo {} | clipboard-copy)') && cd "$dir"
}

# Function to list and open Neovim's oldfiles
function oldf() {
    # Get the oldfiles list from Neovim
    local oldfiles=($(nvim -u NONE --headless +'lua io.write(table.concat(vim.v.oldfiles, "\n") .. "\n")' +qa))
    
    # Filter invalid paths or files not found
    local valid_files=()
    for file in "${oldfiles[@]}"; do
        if [[ -f "$file" ]]; then
            valid_files+=("$file")
        fi
    done
    
    # Use fzf to select from valid files
    local files=($(printf "%s\n" "${valid_files[@]}" | \
        grep -v '\[.*' | \
        fzf --multi \
            --preview 'bat -n --color=always --line-range=:500 {} 2>/dev/null || echo "Error previewing file"' \
            --preview-window 'up,60%,border-bottom,~3' \
            --header 'Neovim oldfiles (recently opened)' \
            --height '80%' \
            --bind 'ctrl-d:execute(echo {} | xargs -r dirname | cd)' \
            --bind 'ctrl-y:execute-silent(echo {} | clipboard-copy)'))
    
    # Open selected files in Neovim
    [[ ${#files[@]} -gt 0 ]] && nvim "${files[@]}"
}

# Function to search files using zoxide and fd
function zf() {
    if [ -z "$1" ]; then
        # No arguments: use fd with fzf to select & open a file
        local file
        file="$(fd --type f \
            --hidden \
            --no-ignore \
            --exclude .git \
            --exclude .git-crypt \
            --exclude .cache \
            --exclude .backup \
            --exclude node_modules \
            --exclude .yarn \
            | fzf \
                --height='80%' \
                --preview='bat -n --color=always --line-range :500 {}' \
                --preview-window 'up,60%,border-bottom,~3' \
                --header 'Search in all files' \
                --bind 'ctrl-d:execute(echo {} | xargs -r dirname | cd)' \
                --bind 'ctrl-y:execute-silent(echo {} | clipboard-copy)'
        )"
        [[ -n "$file" ]] && nvim "$file"
    else
        # Search in zoxide directories
        local lines
        lines=$(zoxide query -l | \
            xargs -I {} fd --type f \
                --hidden \
                --no-ignore \
                --exclude .git \
                --exclude .git-crypt \
                --exclude .cache \
                --exclude .backup \
                --exclude node_modules \
                --exclude .yarn \
                "$1" {})
        
        local line_count
        line_count="$(echo "$lines" | wc -l | xargs)"
        
        if [ -n "$lines" ] && [ "$line_count" -eq 1 ]; then
            # Single match: open directly
            nvim "$lines"
        elif [ -n "$lines" ]; then
            # Multiple matches: allow selection with fzf
            local file
            file=$(echo "$lines" | \
                fzf --query="$1" \
                    --height='80%' \
                    --preview='bat -n --color=always --line-range :500 {}' \
                    --preview-window 'up,60%,border-bottom,~3' \
                    --header "Search results for '$1'" \
                    --bind 'ctrl-d:execute(echo {} | xargs -r dirname | cd)' \
                    --bind 'ctrl-y:execute-silent(echo {} | clipboard-copy)'
            )
            [[ -n "$file" ]] && nvim "$file"
        else
            echo "No matches found." >&2
        fi
    fi
}

# Git heart FZF
# -------------

is_in_git_repo() {
    git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
    fzf --height 90% --min-height 20 --border \
        --bind ctrl-/:toggle-preview "$@" \
        --preview-window=right:60%:wrap
}

# Git file
_gf() {
    is_in_git_repo || return
    git -c color.status=always status --short |
    fzf-down -m --ansi --nth 2..,.. \
        --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
    cut -c4- | sed 's/.* -> //'
}

# Git branch
_gb() {
    is_in_git_repo || return
    git branch -a --color=always | grep -v '/HEAD\s' | sort |
    fzf-down --ansi --multi --tac --preview-window right:70% \
        --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
    sed 's/^..//' | cut -d' ' -f1 |
    sed 's#^remotes/##'
}

# Git tag
_gt() {
    is_in_git_repo || return
    git tag --sort -version:refname |
    fzf-down --multi --preview-window right:70% \
        --preview 'git show --color=always {}'
}

# Git commit hashes
_gh() {
    is_in_git_repo || return
    git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
    fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
        --header 'Press CTRL-S to toggle sort' \
        --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
    grep -o "[a-f0-9]\{7,\}"
}

# Git remote
_gr() {
    is_in_git_repo || return
    git remote -v | awk '{print $1 "\t" $2}' | uniq |
    fzf-down --tac \
        --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
    cut -d$'\t' -f1
}

# Git stash
_gs() {
    is_in_git_repo || return
    git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
    cut -d: -f1
}

# Join lines for git functions
join-lines() {
    local item
    while read item; do
        echo -n "${(q)item} "
    done
}

# Configure git key bindings
() {
    local c
    for c in $@; do
        eval "fzf-g$c-widget() { local result=\$(_g$c | join-lines); zle reset-prompt; LBUFFER+=\$result }"
        eval "zle -N fzf-g$c-widget"
        eval "bindkey '^g^$c' fzf-g$c-widget"
    done
} f b t r h s


# Function to list and kill server processes
function servers() {
    # Get all listening TCP ports and their processes
    local procs=$(lsof -i -sTCP:LISTEN 2>/dev/null | \
        awk 'NR>1 {
            pid=$2;
            port=$9;
            sub(".*:", "", port);
            cmd="pwdx " pid " 2>/dev/null";
            cmd | getline path;
            close(cmd);
            sub("[0-9]+: ", "", path);
            printf "%-6s %-20s %s\n", port, $1, path
        }' | sort -n)

    if [ -z "$procs" ]; then
        echo "No server processes found."
        return 1
    fi

    # Show processes in fzf with preview
    echo "$procs" | \
        fzf --multi \
            --header 'Select processes to kill (Tab to select, Enter to kill)' \
            --preview 'echo "Port: {1}\nProcess: {2}\nDirectory: {3}\n\nDetails:"; ps -p $(lsof -ti:{1}) -o pid,ppid,user,%cpu,%mem,command' \
            --preview-window 'up:6:wrap' \
            --bind 'ctrl-r:reload(lsof -i -sTCP:LISTEN 2>/dev/null)' \
            --bind 'ctrl-/:change-preview-window(down|hidden|)' | \
        awk '{print $1}' | \
        while read port; do
            kill -9 $(lsof -ti:$port)
            echo "Killed process on port $port"
        done
}


# Live grep with ripgrep
function rgf() {
    local initial_query=""
    local rg_prefix="rg --column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git'"

    FZF_DEFAULT_COMMAND="$rg_prefix '$initial_query'" \
    fzf --bind "change:reload:sleep 0.1; $rg_prefix {q} || true" \
        --ansi --disabled --query "$initial_query" \
        --height '80%' \
        --layout=reverse \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --bind 'enter:become(nvim {1} +{2})' \
        --bind 'ctrl-a:select-all' \
        --bind 'ctrl-d:deselect-all' \
        --bind 'ctrl-t:toggle-all'
}