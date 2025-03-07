# Ensure ZDOTDIR is set correctly
: ${ZDOTDIR:="$HOME/.config/zsh"}

# Configuration files to load
config_files=(
    "options"
    "plugins"
    "styles"
    "aliases"
    "keybinds"
    "utility"
)

# Load all configuration files
for conf in "${config_files[@]}"; do
    config_path="$ZDOTDIR/${conf}.zsh"
    if [[ -f "$config_path" ]]; then
        source "$config_path" || echo "Failed to load $conf configuration"
    else
        echo "Warning: Configuration file $conf not found"
    fi
done

# bun completions - using XDG paths
[[ -s "$XDG_DATA_HOME/bun/_bun" ]] && source "$XDG_DATA_HOME/bun/_bun"

# Clean up
unset config_files conf config_path
