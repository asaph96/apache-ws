source ~/.zplugins

export EDITOR='vim'
export KUBE_EDITOR='code -w'
source ~/.aliases
bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

### Brew

export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew";
export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar";
export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew";
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH+:$PATH}";
export MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:${INFOPATH:-}";

### Starship

eval "$(starship init zsh)"
