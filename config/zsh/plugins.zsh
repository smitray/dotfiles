# Initialize zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"


# Important: Load history-substring-search before syntax highlighting
zinit wait lucid for \
    zsh-users/zsh-history-substring-search \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    atinit"zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting


# Load zoxide with correct path handling
zinit ice wait"2" as"command" from"gh-r" lucid \
  pick"zoxide*/zoxide" \
  atclone"./zoxide init zsh > init.zsh" \
  atload'eval "$(zoxide init zsh)"' \
  atpull"%atclone" \
  sbin"zoxide*/zoxide" \
  complement
zinit light ajeetdsouza/zoxide

zinit ice lucid from"gh-r" as"program" mv"fzf -> ${ZPFX}/bin/fzf"
zinit light junegunn/fzf

zinit ice lucid as"program"
zinit snippet 'https://github.com/junegunn/fzf/blob/master/bin/fzf-tmux'


# Load fzf-tab
zinit ice wait lucid
zinit light Aloxaf/fzf-tab

