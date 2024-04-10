---
layout: post
title: Kubernetes cluster on LXC Automated Deployment Guide
date: 2024-02-22
summary: Covers deploying a Kubernetes cluster to an existing LXC cluster via ansible.
categories: guides
---

## Guide results

- X LXC containers deployed
- Kubernetes cluster deployed across those `N` containers
- Single control plane.

## Prerequisites

- Everything is done on `Ubuntu 22.04 LTS server`, however this should work on any system you have LXD running.
- Although the host does not need to be Ubuntu, the deployed VMS MUST be `Ubuntu:22.04` as this is what the script is tuned for. Feel free to change the script slightly to handle other operating systems.
- You already deployed an LXC cluster. See my LXC guide first if you have not.

## Overview

There was some extreme difficulties getting the cluster to deploy into simple containers, with unexplainable errors that made it very difficult to troubleshoot. The modules were loaded correctly, the privileges were set, and everything else listed was done but it would work 50% of the time, which is not reliable enough.

Therefore, I shifted to deploying on LXC virtual machines, compared to LXC containers. Although this adds overhead, it still has all the benefits of LXC allowing easy movement between nodes, replication, ceph storage usage, etc.

The script below will handle deploying the LXC vms for you and setting up kubeadm inside. You will end with a running cluster.

{% raw %}

```yaml
- hosts: all
  become: yes
  vars:
    # Must container master in the name
    control_plane: "kmaster"
    # Worker names, kworker-1 , kworker-2, kworker-3, ... kworker-{{ number_of_workers }}
    worker_prefix: "kworker"
    number_of_workers: 2
  tasks:
    - name: Set limits for default profile
      shell: |
        lxc profile set default limits.memory=2GB
        lxc profile set default limits.cpu=2

    - name: Create worker vms
      shell: |
        lxc launch ubuntu:22.04 {{ item }} --vm --profile default
      loop: "{{ range(1, number_of_workers|int + 1) | map('string') | map('regex_replace', '^', worker_prefix) | map('join', '') | list }}"

    - name: Create worker vms
      shell: |
        lxc launch ubuntu:22.04 {{ control_plane }} --vm --profile default

    - name: This adds delay to ensure IPS get assigned. If further tasks fail it is most likely due to this not waiting long enough.
      # TODO: Make this better to grab IPs directly then do health check
      # wait_for:
      #   host: "{{ control_plane }}"
      #   port: 22
      #   delay: 10
      #   timeout: 300
      shell:
        cmd: sleep 120

    - name: Copy over script
      copy:
        content: |
          #!/bin/bash
          # Create /etc/modules-load.d/k8s.conf for all worker nodes
          cat <<EOL | sudo tee /etc/modules-load.d/k8s.conf
          overlay
          br_netfilter
          EOL

          # Load the modules
          sudo modprobe overlay
          sudo modprobe br_netfilter

          # Configure kernel parameters for all nodes
          cat <<EOL | sudo tee /etc/sysctl.d/k8s.conf
          net.bridge.bridge-nf-call-iptables  = 1
          net.bridge.bridge-nf-call-ip6tables = 1
          net.ipv4.ip_forward                 = 1
          EOL

          # Apply the changes
          sudo sysctl --system
          sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gpg gnupg
          sudo install -m 0755 -d /etc/apt/keyrings
          curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
          sudo chmod a+r /etc/apt/keyrings/docker.gpg
          echo "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
          sudo apt-get update && sudo apt-get install -y containerd.io
          containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
          sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
          sudo systemctl restart containerd && sudo systemctl enable containerd
          curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
          echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
          sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl && sudo apt-mark hold kubelet kubeadm kubectl

          if [[ $(hostname) =~ .*master.* ]]
          then

            echo "[TASK 8] Initialize Kubernetes Cluster"
            kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all >> /root/kubeinit.log 2>&1

            echo "[TASK 9] Copy kube admin config to root user .kube directory"
            mkdir /root/.kube
            cp /etc/kubernetes/admin.conf /root/.kube/config

            echo "[TASK 10] Deploy Calico network"
            kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
          fi
        dest: /tmp/kubernetes_setup_script.sh
        mode: "0755"

    - name: Execute on masters.
      shell: |
        lxc file push /tmp/kubernetes_setup_script.sh  {{ control_plane }}/root/
        lxc exec {{ control_plane }} -- chmod +x /root/kubernetes_setup_script.sh
        lxc exec {{ control_plane }} -- /root/kubernetes_setup_script.sh

    - name: Execute on workers
      shell: |
        lxc file push /tmp/kubernetes_setup_script.sh  {{ item }}/root/
        lxc exec {{ item }} -- chmod +x /root/kubernetes_setup_script.sh
        lxc exec {{ item }} -- /root/kubernetes_setup_script.sh
      loop: "{{ range(1, number_of_workers|int + 1) | map('string') | map('regex_replace', '^', worker_prefix) | map('join', '') | list }}"

    - name: Delete a file
      file:
        path: /tmp/kubernetes_setup_script.sh
        state: absent

    - name: Generate and save cluster join command to /joincluster.sh
      shell: |
        lxc exec {{ control_plane }} -- /bin/bash -c 'kubeadm token create --print-join-command'
      register: join_command_result

    - name: Execute on workers
      shell: |
        lxc exec {{ item }} -- /bin/bash -c '{{ join_command_result.stdout }}'
      loop: "{{ range(1, number_of_workers|int + 1) | map('string') | map('regex_replace', '^', worker_prefix) | map('join', '') | list }}"
```

{% endraw %}
An example command to run this would be,

```bash
ansible-playbook -i inventoryFile.ini thisPlaybook.yml
```

Where your inventory looks similiar to the following,

```yaml
[masters]
10.35.40.60 ansible_host=10.35.40.60 # Node you set LXD up on

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_become_pass="{{ lookup('onepassword', '10.35.40.60', field='password') }}" # Replace your secrets here
ansible_user="{{ lookup('onepassword', '10.35.40.60', field='username') }}" # Replace your secrets here
ansible_become_method=sudo
ansible_become=yes
```
