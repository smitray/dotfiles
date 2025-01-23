# If ZDOTDIR is not set, set it
[[ -z "$ZDOTDIR" ]] && export ZDOTDIR="$HOME/.config/zsh"

# Load all configuration files
for conf in "$ZDOTDIR"/{options,plugins,styles,prompt,aliases,keybinds,utility}.zsh; do
    [[ -f "$conf" ]] && source "$conf"
done
