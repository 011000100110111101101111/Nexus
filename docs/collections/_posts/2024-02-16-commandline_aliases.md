---
layout: post
title: Useful aliases for the command line
date: 2024-02-16
summary: Congregates numerous aliases I have created / adapted from others.
categories: programming aliases
---

**Guide results**

- Learn some useful aliases.

**Prerequisites / Important Information**

- None

This is where I will collect aliases I find useful for different purposes. I will try my best to credit others when I have found it somewhere. This will also constantly be updated as I find / create more.

## Kubernetes

These two will let you interactively choose pods / services and peek their configuration real time. It will also print the full describe of the pod / service after.

```bash
alias kpods='kubectl get pods -A --no-headers | awk "{print \$2, \$1}" | fzf --ansi --multi --preview "kubectl describe pod {1} -n {2}" | xargs -n 2 sh -c "kubectl describe pod \$0 -n \$1"'
alias kservices='kubectl get services -A --no-headers | awk "{print \$2, \$1}" | fzf --ansi --multi --preview "kubectl describe services {1} -n {2}" | xargs -n 2 sh -c "kubectl describe services \$0 -n \$1"'
```

Lets go a bit further and parse out specific things in the preview window that I would find important and want to see all the time.

```bash
alias kpodsshort='kubectl get pods -A --no-headers | awk "{print \$2, \$1}" | fzf --ansi --multi --preview "kubectl describe pod {1} -n {2} | awk '\''/^IP:/ {print \"IP: \" \$2} ; /^Name:/ {print \"Name: \" \$2} ; /^Namespace:/ {print \"Namespace: \" \$2} ; /^Node:/ {print \"Node: \" \$2} ; /^Status:/ {print \"Status: \" \$2} ; /^Service Account:/ {print \"Service Account: \" \$3} ; /^Image:/ {print \"Image: \" \$2} ; /^Ports:/ {print \"Ports: \" \$2} ; /^Host Ports:/ {print \"Host Ports: \" \$2} ; /^State:/ {print \"State: \" \$2} ; /^Ready:/ {print \"Ready: \" \$2}'\''" | xargs -n 2 sh -c "kubectl describe pod \$0 -n \$1"'
```

## Ansible

This doozy will allow you to interactively and visually choose a ansible playbook then choose an inventory file for it, then execute it. This requires `fzf` package to be installed on the system. You can change ./ to always search certain directories on your system, or search the entire directory, etc. Currently it searches the current directory and any subdirectores.

```bash
alias run-ansible='find ./ -type f -name "*.yml" -printf "%P\n" | fzf --multi --ansi --preview "cat {}" --preview-window=right:60%:wrap | awk "{print \$1}" | xargs -I {} sh -c '\''echo {} && find ./ -type f -name "*.ini" -printf "%P\n" | fzf --ansi --preview "cat {}" --preview-window=right:60%:wrap'\'' | xargs -n 2 sh -c "ansible-playbook \$0 -i \$1"'
```
