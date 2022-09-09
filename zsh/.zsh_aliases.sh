# Utils
alias cl='clear'
alias c='code .'
alias cdf='cd $(ls | fzf)'
alias ce='code . && exit'

# Exa
alias ls='exa'
alias l='exa -l --time-style=long-iso --git --color-scale'
alias la='exa -la --time-style=long-iso --git --color-scale'
alias lt='exa --tree --level=2'

alias pginit='pg_ctl initdb'
alias pgstart='pg_ctl start -o "-k `pwd`/postgres"'
alias pgstop='pg_ctl stop'
alias pgstatus='pg_ctl status'

# Lazygit
alias lg='lazygit'

# Project specific aliases

alias ybw='yarn build:watch'
alias fts='firebase emulators:start --import=./exports --export-on-exit'
