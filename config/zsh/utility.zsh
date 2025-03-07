# Function to list and kill server processes
# Usage: server_manager
#   - Shows a list of all running server processes with ports
#   - Navigate with arrow keys, select with Tab, kill with Enter
#   - Alt+k for graceful kill, Ctrl+/ to toggle preview
function server_manager() {
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
            
            # Get command to identify technology
            cmd="ps -p " pid " -o command= | head -c 30";
            cmd | getline command;
            close(cmd);
            
            # Color coding based on technology
            tech="";
            color="";
            if (command ~ /node/) { tech="node"; color="\033[32m"; }      # green
            else if (command ~ /python/) { tech="python"; color="\033[34m"; } # blue
            else if (command ~ /bun/) { tech="bun"; color="\033[35m"; }    # magenta
            else if (command ~ /deno/) { tech="deno"; color="\033[36m"; }   # cyan
            else if (command ~ /go/) { tech="go"; color="\033[33m"; }     # yellow
            else { tech="other"; color="\033[37m"; }                      # white
            
            printf "%s%-6s\033[0m %s%-12s\033[0m %-20s %s\n", color, port, color, tech, $1, path;
        }' | sort -n)

    if [ -z "$procs" ]; then
        echo "No server processes found."
        return 1
    fi

    # Show processes in fzf with improved preview
    echo "$procs" | \
        fzf --multi \
            --ansi \
            --header 'Server Manager | Tab: select | Enter: kill -9 | Alt-k: kill | Ctrl-/: toggle preview' \
            --preview 'port=$(echo {1} | tr -d "\033[32m\033[34m\033[35m\033[36m\033[33m\033[37m\033[0m"); 
                      pid=$(lsof -ti:$port);
                      echo -e "\033[1mPort:\033[0m {1}\n\033[1mType:\033[0m {2}\n\033[1mProcess:\033[0m {3}\n\033[1mDirectory:\033[0m {4}\n\n\033[1mDetails:\033[0m"; 
                      ps -p $pid -o pid,ppid,user,%cpu,%mem,start,command' \
            --preview-window 'up:7:wrap' \
            --bind 'ctrl-/:change-preview-window(down|hidden|)' \
            --bind 'alt-k:execute(echo {1} | tr -d "\033[32m\033[34m\033[35m\033[36m\033[33m\033[37m\033[0m" | xargs -I % sh -c "kill \$(lsof -ti:%)")' | \
        tr -d '\033[32m\033[34m\033[35m\033[36m\033[33m\033[37m\033[0m' | \
        awk '{print $1}' | \
        while read port; do
            kill -9 $(lsof -ti:$port)
            echo -e "\033[31mKilled process on port $port\033[0m"
        done
}

# Interactive grep with ripgrep and preview
# Usage: live_grep [initial_query]
#   - Type to search file contents in real-time
#   - Enter to open the selected file at the matching line
#   - Ctrl+y to copy file:line to clipboard
#   - Ctrl+/ to toggle preview
function live_grep() {
    local initial_query="${*:-}"
    local rg_prefix="rg --column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git' --glob '!node_modules'"

    FZF_DEFAULT_COMMAND="$rg_prefix '$initial_query'" \
    fzf --bind "change:reload:sleep 0.1; $rg_prefix {q} || true" \
        --ansi --disabled --query "$initial_query" \
        --height '90%' \
        --layout=reverse \
        --delimiter : \
        --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --header 'Live Grep | Enter: open in nvim | Ctrl-y: copy to clipboard | Ctrl-/: toggle preview' \
        --bind 'enter:become(${EDITOR:-nvim} {1} +{2})' \
        --bind 'ctrl-a:select-all' \
        --bind 'ctrl-d:deselect-all' \
        --bind 'ctrl-t:toggle-all' \
        --bind 'ctrl-/:toggle-preview' \
        --bind 'ctrl-y:execute-silent(echo {1}:{2} | wl-copy)'
}

# Quick Find and Open
# Usage: quick_find
#   - Finds files from project root (git) or current directory
#   - Shows previews with syntax highlighting
#   - Enter to open selected file in $EDITOR
#   - Ctrl+y to copy file path, Ctrl+/ to toggle preview
quick_find() {
    # Determine the project root (fallback to current directory if not in a Git repo)
    local root_dir
    root_dir=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    # Use find from the project root
    local file
    file=$(find "$root_dir" -type f \
            -not -path "*/\.*" \
            -not -path "*/node_modules/*" \
            -not -path "*/build/*" \
            -not -path "*/dist/*" \
            -maxdepth 5 2>/dev/null | \
        fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' \
            --preview-window 'right:60%' \
            --header "Quick file open | Ctrl-/: toggle preview | Ctrl-y: copy path" \
            --bind 'ctrl-/:toggle-preview' \
            --bind 'ctrl-y:execute-silent(echo {} | wl-copy)')
    # Open the selected file if not empty
    if [[ -n "$file" ]]; then
        ${EDITOR:-nvim} "$file"
    fi
}

# Access and open recent Neovim files
# Usage: nvim_recent
#   - Lists files recently opened in Neovim
#   - Shows previews with syntax highlighting
#   - Enter to open selected file(s)
#   - Tab to select multiple files
#   - Ctrl+y to copy file path, Ctrl+/ to toggle preview
nvim_recent() {
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
            --preview 'bat -n --color=always --line-range=:500 {} 2>/dev/null || echo "Preview not available"' \
            --preview-window 'up,60%,border-bottom,~3' \
            --header 'Recent Neovim Files | Ctrl-y: copy path | Ctrl-/: toggle preview' \
            --height '80%' \
            --bind 'ctrl-d:execute(echo {} | xargs -r dirname | cd)' \
            --bind 'ctrl-y:execute-silent(echo {} | wl-copy)' \
            --bind 'ctrl-/:toggle-preview'))
    
    # Open selected files in Neovim
    if [[ ${#files[@]} -gt 0 ]]; then
        ${EDITOR:-nvim} "${files[@]}"
    fi
}

# Enhanced zoxide file search
# Usage: zoxide_find [query]
#   - Without args: Find files in current directory
#   - With args: Search for matching files across frequently visited directories
#   - Results are limited to 15 top directories for performance
#   - Enter to open selected file in $EDITOR
#   - Ctrl+y to copy file path, Ctrl+/ to toggle preview
zoxide_find() {
    if [ -z "$1" ]; then
        # No arguments: find files in current directory
        local file
        file="$(fd --type f \
            --hidden \
            --no-ignore \
            --exclude .git \
            --exclude node_modules \
            | fzf \
                --height='80%' \
                --preview='bat -n --color=always --line-range :500 {}' \
                --preview-window 'up,60%,border-bottom,~3' \
                --header 'Search files in current directory | Ctrl-/: toggle preview | Ctrl-y: copy path' \
                --bind 'ctrl-/:toggle-preview' \
                --bind 'ctrl-y:execute-silent(echo {} | wl-copy)'
        )"
        # Open the selected file if not empty
        if [[ -n "$file" ]]; then
            ${EDITOR:-nvim} "$file"
        fi
    else
        # With arguments: search in zoxide directories
        echo "🔍 Searching for \"$1\" in frequently used directories..."
        
        # Get top directories from zoxide (limit to 15 for performance)
        local top_dirs=($(zoxide query -l | head -15))
        local results=()
        
        # Search in each directory and collect results
        for dir in "${top_dirs[@]}"; do
            local dir_results=($(fd --type f --hidden "$1" "$dir" 2>/dev/null))
            results+=("${dir_results[@]}")
        done
        
        # Count results
        local result_count=${#results[@]}
        
        if [ "$result_count" -eq 0 ]; then
            echo "No files matching \"$1\" found in your frequent directories."
            return 1
        elif [ "$result_count" -eq 1 ]; then
            # Single match: open directly
            echo "Found one match: ${results[0]}"
            # Open the selected file if not empty
            if [[ -n "${results[0]}" ]]; then
                ${EDITOR:-nvim} "${results[0]}"
            fi
        else
            # Multiple matches: allow selection with fzf
            echo "Found $result_count matches."
            local file
            file=$(printf '%s\n' "${results[@]}" | \
                fzf --query="$1" \
                    --height='80%' \
                    --preview='bat -n --color=always --line-range :500 {}' \
                    --preview-window 'up,60%,border-bottom,~3' \
                    --header "Search results for '$1' | Ctrl-/: toggle preview | Ctrl-y: copy path" \
                    --bind 'ctrl-/:toggle-preview' \
                    --bind 'ctrl-y:execute-silent(echo {} | wl-copy)'
            )
            # Open the selected file if not empty
            if [[ -n "$file" ]]; then
                ${EDITOR:-nvim} "$file"
            fi
        fi
    fi
}

# Integration with lf file manager for directory changing
# Usage: lfcd
#   - Opens lf file manager
#   - When exiting lf, automatically changes to the last directory you were in
#   - Makes lf work like a directory navigator
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}


# Clipboard history management with cliphist
# Usage: clipboard_history
#   - Shows recent clipboard entries using cliphist
#   - Enter to select an entry and copy it to the current clipboard
#   - Ctrl+d to delete an entry from history
#   - Useful for recalling previously copied items
clipboard_history() {
    local selected
    selected=$(cliphist list | \
        fzf --reverse \
            --header 'Clipboard History | Enter: select | Ctrl-d: delete entry' \
            --preview 'echo {1} | cliphist decode' \
            --preview-window 'up:60%:wrap' \
            --bind 'ctrl-d:execute(echo {1} | cliphist delete)+reload(cliphist list)')
    
    if [[ -n "$selected" ]]; then
        echo "$selected" | cliphist decode | wl-copy
    fi
}
