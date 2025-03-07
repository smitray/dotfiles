# Load required modules
zmodload -i zsh/complist

# History configuration
HISTFILE="$ZDOTDIR/.zhistory"
HISTSIZE=10000
SAVEHIST=10000

# History options
setopt appendhistory            # Append to history file
setopt SHARE_HISTORY           # Share history between sessions
setopt HIST_EXPIRE_DUPS_FIRST  # Expire duplicate entries first
setopt HIST_IGNORE_DUPS        # Don't record duplicates
setopt HIST_FIND_NO_DUPS       # Ignore duplicates when searching
setopt HIST_REDUCE_BLANKS      # Remove blank lines
setopt HIST_VERIFY             # Show command before executing from history
setopt HIST_IGNORE_SPACE       # Don't record commands starting with space
setopt HIST_SAVE_NO_DUPS       # Don't save duplicates
setopt HIST_IGNORE_ALL_DUPS    # Remove older duplicate entries
setopt INC_APPEND_HISTORY      # Add commands to history immediately

# Directory options
setopt AUTO_CD                 # cd by typing directory name
setopt AUTO_PUSHD             # Push directory to stack automatically
setopt PUSHD_IGNORE_DUPS      # Don't push duplicates to stack
setopt PUSHD_MINUS            # Exchange meaning of + and - for pushd
setopt AUTO_LIST              # List choices on ambiguous completion
setopt AUTO_MENU              # Show completion menu on successive tab
setopt ALWAYS_TO_END          # Move cursor to end of word on completion
setopt COMPLETE_IN_WORD       # Complete from both ends of word
setopt PUSHD_TO_HOME          # pushd with no args goes to home
setopt PUSHD_SILENT          # Don't print directory stack

# Completion options
setopt COMPLETE_ALIASES       # Treat aliases as distinct commands
setopt LIST_PACKED           # Make completion list smaller
setopt LIST_TYPES            # Show file types in completion list

# Other options
setopt EXTENDED_GLOB          # Extended globbing
setopt NOMATCH               # Error if glob has no matches
setopt NOTIFY                # Report status of background jobs immediately
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive shells
setopt NO_BG_NICE            # Don't nice background tasks
setopt NO_HUP               # Don't kill background jobs when shell exits
setopt PROMPT_SUBST         # Enable parameter expansion in prompts
setopt LONG_LIST_JOBS       # List jobs in long format
unsetopt BEEP               # No beep on error
unsetopt FLOW_CONTROL       # Disable start/stop characters
unsetopt CASE_GLOB         # Case insensitive globbing

# Initialize completion system
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Ensure zsh completion directory exists
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"

# SSH Agent configuration - more robust version
if [[ -z "${SSH_AUTH_SOCK}" && -z "${SSH_CLIENT}" ]]; then
    eval "$(ssh-agent -t 3600 2>/dev/null)" >/dev/null || echo "Failed to start ssh-agent"
fi

# Load additional completions if they exist
fpath=($ZDOTDIR/completions $fpath)