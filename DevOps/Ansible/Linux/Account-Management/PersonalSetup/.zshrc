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

# Kubernetes related aliases
alias kpods='kubectl get pods -A --no-headers | awk "{print \$2, \$1}" | fzf --ansi --multi --preview "kubectl describe pod {1} -n {2}" | xargs -n 2 sh -c "kubectl describe pod \$0 -n \$1"'
alias kservices='kubectl get services -A --no-headers | awk "{print \$2, \$1}" | fzf --ansi --multi --preview "kubectl describe services {1} -n {2}" | xargs -n 2 sh -c "kubectl describe services \$0 -n \$1"'
alias kpodsshort='kubectl get pods -A --no-headers | awk "{print \$2, \$1}" | fzf --ansi --multi --preview "kubectl describe pod {1} -n {2} | awk '\''/^IP:/ {print \"IP: \" \$2} ; /^Name:/ {print \"Name: \" \$2} ; /^Namespace:/ {print \"Namespace: \" \$2} ; /^Node:/ {print \"Node: \" \$2} ; /^Status:/ {print \"Status: \" \$2} ; /^Service Account:/ {print \"Service Account: \" \$3} ; /^Image:/ {print \"Image: \" \$2} ; /^Ports:/ {print \"Ports: \" \$2} ; /^Host Ports:/ {print \"Host Ports: \" \$2} ; /^State:/ {print \"State: \" \$2} ; /^Ready:/ {print \"Ready: \" \$2}'\''" | xargs -n 2 sh -c "kubectl describe pod \$0 -n \$1"'
alias kconfig='kubectl get namespaces -A --no-headers | awk "{print \$1}" | fzf --ansi --multi --preview "kubectl get pods -n {1}" | xargs -n 2 sh -c "kubectl config set-context --current --namespace=\$0"'
# Ansible related aliases
alias run-ansible='find ./ -type f -name "*.yml" -printf "%P\n" | fzf --multi --ansi --preview "cat {}" --preview-window=right:60%:wrap | awk "{print \$1}" | xargs -I {} sh -c '\''echo {} && find ./ -type f -name "*.ini" -printf "%P\n" | fzf --ansi --preview "cat {}" --preview-window=right:60%:wrap'\'' | xargs -n 2 sh -c "ansible-playbook \$0 -i \$1"'

# TODO: Create ansible parser with fuzzy menu, can let us choose the playbook and the inventory file
