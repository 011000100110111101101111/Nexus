# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="spaceship"

plugins=(
  git zsh-autocomplete zsh-syntax-highlighting
  kubectl aliases ansible
  colored-man-pages colorize command-not-found
  docker docker-compose emoji-clock
  firewalld git git-prompt
  helm history last-working-dir
  lxd nmap podman
  ripgrep systemd thefuck
  themes timer transfer
  ufw vault web-search
  vscode zsh-interactive-cd zoxide
)

source $ZSH/oh-my-zsh.sh

eval $(thefuck --alias redo)

alias k8-master-1="ssh alex@10.35.40.60"
alias k8-worker-1="ssh alex@10.35.40.70"
alias k8-worker-2="ssh alex@10.35.40.71"
