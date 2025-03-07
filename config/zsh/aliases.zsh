# -------------------------------------
# Helper Functions
# -------------------------------------

# Git branch/status utility functions
function git_current_branch() {
  local ref
  ref=$(git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return
    ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,master}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return
    fi
  done
  echo master
}

function git_develop_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local branch
  for branch in dev devel development; do
    if command git show-ref -q --verify refs/heads/$branch; then
      echo $branch
      return
    fi
  done
  echo develop
}

# Quick directory creation and navigation
take() {
  mkdir -p $1
  cd $1
}

# Extract various archive formats
extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Directory usage report
dusage() {
  du -d 1 -h $1 | sort -hr
}

# Find process by name
fps() {
  ps aux | grep -i $1 | grep -v grep
}

# --------------------------------
# Git Aliases
# --------------------------------
# Custom git fuzzy finder
alias gs='gfn.zsh'
alias gsf='gfn.zsh files'
alias gsb='gfn.zsh branches'
alias gsc='gfn.zsh commits'
alias gss='gfn.zsh stash'
alias tx='tx.zsh'

# Standard git shortcuts
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gam='git am'
alias gama='git am --abort'
alias gamc='git am --continue'
alias gams='git am --skip'
alias gamscp='git am --show-current-patch'
alias gap='git apply'
alias gapa='git add --patch'
alias gapt='git apply --3way'
alias gau='git add --update'
alias gav='git add --verbose'
alias gb='git branch'
alias gbD='git branch -D'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbda='git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs git branch -d 2>/dev/null'
alias gbl='git blame -b -w'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcam='git commit -a -m'
alias gcan!='git commit -v -a --no-edit --amend'
alias gcans!='git commit -v -a -s --no-edit --amend'
alias gcas='git commit -a -s'
alias gcasm='git commit -a -s -m'
alias gcb='git checkout -b'
alias gcd='git checkout $(git_develop_branch)'
alias gcf='git config --list'
alias gcl='git clone --recurse-submodules'
alias gclean='git clean -id'
alias gcm='git checkout $(git_main_branch)'
alias gcmsg='git commit -m'
alias gcn!='git commit -v --no-edit --amend'
alias gco='git checkout'
alias gcor='git checkout --recurse-submodules'
alias gcount='git shortlog -sn'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gcs='git commit -S'
alias gcsm='git commit -s -m'
alias gcss='git commit -S -s'
alias gcssm='git commit -S -s -m'
alias gd='git diff'
alias gdca='git diff --cached'
alias gdct='git describe --tags $(git rev-list --tags --max-count=1)'
alias gdcw='git diff --cached --word-diff'
alias gds='git diff --staged'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdup='git diff @{upstream}'
alias gdw='git diff --word-diff'
alias gf='git fetch'
alias gfa='git fetch --all --prune --jobs=10'
alias gfg='git ls-files | grep'
alias gfo='git fetch origin'
alias gg='git gui citool'
alias gga='git gui citool --amend'
alias ggpull='git pull origin "$(git_current_branch)"'
alias ggpush='git push origin "$(git_current_branch)"'
alias ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
alias ghh='git help'
alias gignore='git update-index --assume-unchanged'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
alias git-svn-dcommit-push='git svn dcommit && git push github $(git_main_branch):svntrunk'
alias gk='\gitk --all --branches &!'
alias gke='\gitk --all $(git log -g --pretty=%h) &!'
alias gl='git pull'
alias glg='git log --stat'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glgp='git log --stat -p'
alias glo='git log --oneline --decorate'
alias glob='git log --oneline --decorate --branches'
alias glod='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'\'
alias glods='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'\'' --date=short'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glol='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'\'
alias glola='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'\'' --all'
alias glols='git log --graph --pretty='\''%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'\'' --stat'
alias glum='git pull upstream $(git_main_branch)'
alias gm='git merge'
alias gma='git merge --abort'
alias gmom='git merge origin/$(git_main_branch)'
alias gms='git merge --squash'
alias gmtl='git mergetool --no-prompt'
alias gmtlvim='git mergetool --no-prompt --tool=vimdiff'
alias gmum='git merge upstream/$(git_main_branch)'
alias gp='git push'
alias gpd='git push --dry-run'
alias gpf='git push --force-with-lease'
alias gpf!='git push --force'
alias gpoat='git push origin --all && git push origin --tags'
alias gpr='git pull --rebase'
alias gpristine='git reset --hard && git clean -dffx'
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias gpu='git push upstream'
alias gpv='git push -v'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbd='git rebase $(git_develop_branch)'
alias grbi='git rebase -i'
alias grbm='git rebase $(git_main_branch)'
alias grbo='git rebase --onto'
alias grbom='git rebase origin/$(git_main_branch)'
alias grbs='git rebase --skip'
alias grev='git revert'
alias grh='git reset'
alias grhh='git reset --hard'
alias grm='git rm'
alias grmc='git rm --cached'
alias grmv='git remote rename'
alias groh='git reset origin/$(git_current_branch) --hard'
alias grrm='git remote remove'
alias grs='git restore'
alias grset='git remote set-url'
alias grss='git restore --source'
alias grst='git restore --staged'
alias grt='cd "$(git rev-parse --show-toplevel || echo .)"'
alias gru='git reset --'
alias grup='git remote update'
alias grv='git remote -v'
alias gsb='git status -sb'
alias gsd='git svn dcommit'
alias gsh='git show'
alias gsi='git submodule init'
alias gsps='git show --pretty=short --show-signature'
alias gsr='git svn rebase'
alias gsst='git status -s'  # Renamed to avoid conflict with fuzzy finder
alias gst='git status'
alias gsta='git stash push'
alias gstaa='git stash apply'
alias gstall='git stash --all'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gstu='git stash --include-untracked'
alias gsu='git submodule update'
alias gsw='git switch'
alias gswc='git switch -c'
alias gswd='git switch $(git_develop_branch)'
alias gswm='git switch $(git_main_branch)'
alias gtl='gtl(){ git tag --sort=-v:refname -n -l "${1}*" }; noglob gtl'
alias gts='git tag -s'
alias gtv='git tag | sort -V'
alias gunignore='git update-index --no-assume-unchanged'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
alias gup='git pull --rebase'
alias gupa='git pull --rebase --autostash'
alias gupav='git pull --rebase --autostash -v'
alias gupv='git pull --rebase -v'
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'

# Other version control
alias lg='lazygit'

# --------------------------------
# Navigation & Directory Aliases
# --------------------------------

# Zoxide aliases (for better directory navigation)
alias cd="z"
alias zf='zoxide_find'

# Directory movement shortcuts
alias ~='cd'

# Directory listing with eza
alias ls='eza --color=auto'
alias ll='eza -la --header --git'
alias la='eza -a'
alias lt='eza --tree'
alias l='eza -l'

alias c= 'clear'

# --------------------------------
# Development Environment Aliases
# --------------------------------

# Node.js
alias n='node'
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'
alias nrb='npm run build'
alias nrd='npm run dev'

# Yarn
alias y='yarn'
alias ya='yarn add'
alias yad='yarn add -D'
alias yd='yarn dev'
alias ys='yarn start'
alias yt='yarn test'
alias yb='yarn build'
alias yi='yarn install'
alias yu='yarn upgrade'

# pnpm
alias pn='pnpm'
alias pni='pnpm install'
alias pna='pnpm add'
alias pnad='pnpm add -D'
alias pnr='pnpm run'
alias pns='pnpm start'
alias pnt='pnpm test'
alias pnb='pnpm run build'
alias pnd='pnpm run dev'

# Bun.js
alias b='bun'
alias br='bun run'
alias bi='bun install'
alias ba='bun add'
alias bad='bun add -d'
alias bs='bun start'
alias bt='bun test'
alias bd='bun dev'

# Deno
alias d='deno'
alias dr='deno run'
alias dt='deno test'
alias df='deno fmt'
alias db='deno bundle'
alias dca='deno cache'

# Python
alias py='python'
alias py3='python3'
alias pyi='pip install'
alias pyu='pip uninstall'
alias pyv='python -m venv venv'
alias pya='source venv/bin/activate'
alias pytest='python -m pytest'
alias jl='jupyter lab'

# Go
alias gr='go run'
alias gb='go build'
alias gt='go test'
alias gm='go mod'
alias gmt='go mod tidy'
alias gi='go install'
alias gofmt='go fmt'

# PHP
alias php7='/usr/bin/php7'
alias php8='/usr/bin/php8'
alias comp='composer'
alias ci='composer install'
alias cu='composer update'
alias cr='composer require'
alias cda='composer dump-autoload'

# --------------------------------
# System Administration
# --------------------------------

alias c='clear'

# Pacman - Arch package manager
alias pac='sudo pacman'
alias pacq='pacman -Q'
alias pacs='sudo pacman -S'
alias pacsy='sudo pacman -Sy'
alias pacsu='sudo pacman -Su'
alias pacsyu='sudo pacman -Syu'
alias pacr='sudo pacman -R'
alias pacrs='sudo pacman -Rs'
alias pacrns='sudo pacman -Rns'  # Complete removal including dependencies and configs
alias pacclean='sudo pacman -Sc'
alias pacdb='sudo pacman -Syy'
alias pacinfo='pacman -Qi'
alias pacls='pacman -Ql'
alias pacfiles='pacman -Fl'
alias pacorphans='sudo pacman -Rns $(pacman -Qtdq)'
alias pacmirrors='sudo reflector --sort rate --country India --latest 10 --protocol https --save /etc/pacman.d/mirrorlist'

# Paru - AUR helper
alias p='paru'
alias pq='paru -Q'
alias ps='paru -S'
alias psy='paru -Sy'
alias psu='paru -Su'
alias psyu='paru -Syu'
alias pr='paru -R'
alias prs='paru -Rs'
alias prns='paru -Rns'  # Complete removal including dependencies and configs

# System utilities
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -m'
alias mkdir='mkdir -p'
alias cpr='cp -r'
alias rmr='rm -r'
alias srmr='sudo rm -r'
alias cat='bat'
alias systemctl='sudo systemctl'
alias journalctl='sudo journalctl'

# Process management
alias psa='ps aux'
alias psg='ps aux | grep'
alias k9='kill -9'

# --------------------------------
# Configuration Management
# --------------------------------

# Quick config directory navigation
alias zshconf='cd $XDG_CONFIG_HOME/zsh'
alias nvimconf='cd $XDG_CONFIG_HOME/nvim'
alias tmuxconf='cd $XDG_CONFIG_HOME/tmux'
alias lfconf='cd $XDG_CONFIG_HOME/lf'
alias aliasedit='$EDITOR $XDG_CONFIG_HOME/zsh/aliases.zsh'
alias reload='source $XDG_CONFIG_HOME/zsh/.zshrc'
alias vim='nvim'
alias vi='nvim'

# --------------------------------
# JSON Processing with jq
# --------------------------------
alias jq='jq -C'  # Colorized output by default
alias jql='jq -C . | less -R'  # View JSON with paging
alias jqp='jq -C . | pygmentize -l json'  # Pretty print with syntax highlighting
alias jqs='jq -S'  # Sort keys
alias jqc='jq -c'  # Compact output

# --------------------------------
# Useful Utility Aliases
# --------------------------------

# File searching and navigation
alias fd='fd --hidden --exclude .git'
alias f='find . -name'
alias rg='rg --hidden --glob "!.git"'

# No need for individual archive aliases since we have the extract function

# Docker and Docker Compose
alias d='docker'
alias dc='docker-compose'
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dclogs='docker-compose logs -f'

# Networking
alias myip='curl http://ipecho.net/plain; echo'
alias ports='netstat -tulanp'
alias listen='netstat -tulanp | grep LISTEN'
