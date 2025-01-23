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

# Directory options
setopt AUTO_CD                 # cd by typing directory name
setopt AUTO_PUSHD             # Push directory to stack automatically
setopt PUSHD_IGNORE_DUPS      # Don't push duplicates to stack
setopt PUSHD_MINUS            # Exchange meaning of + and - for pushd
setopt AUTO_LIST              # List choices on ambiguous completion
setopt AUTO_MENU              # Show completion menu on successive tab
setopt ALWAYS_TO_END          # Move cursor to end of word on completion
setopt COMPLETE_IN_WORD       # Complete from both ends of word

# Other options
setopt EXTENDED_GLOB          # Extended globbing
setopt NOMATCH               # Error if glob has no matches
setopt NOTIFY                # Report status of background jobs immediately
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive shells
unsetopt BEEP                # No beep on error
unsetopt FLOW_CONTROL        # Disable start/stop characters

# Initialize completion system
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"