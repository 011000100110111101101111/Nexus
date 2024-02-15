---
layout: post
title: Kubernetes Deployment on Bare Metal
date: 2024-02-15
summary: Kubernetes deployment to bare metal
categories: orchestration devops
---

We will discuss the deployment of kubernetes on bare metal machines. We will look into the considerations needed when using bare metal compared to cloud, as well as discussing the benefits of certain "plugins" compared to others. All of this comes from my research during implementing k8s in my homelab, as well as in the CCDC.

To be more specific, I will cover deploying [Kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/) across 1 master node and 2 worker nodes. First, we will cover the manual steps required, then look at an ansible playbook to take care of these manual steps instead.

**Another consideration is this was all done on `ubuntu 22.04 LTS server` nodes**

The topics we will cover consist of,

- Pre-Installation Requirements
- Deploying the cluster
- CNI setup
- CSI setup
- Loadbalancer setup
- Ingress setup
- Automated Deployment with Ansible
- Resources

## Pre-Installation Requirements

TODO: Finish up

### Deploying Bare metal K8 cluster across 1 control and 2 worker nodes

First disable Swap file.

```bash
# To check if swap is on
sudo swapon --show

# temporarily disable swap file
sudo swapoff -a

# Permanently disable swap file
sudo swapoff -a
sudo rm /swap.img

# edit and remove the /swap.img line.
sudo vim /etc/fstab

# check its off
sudo swapon --show
```

Now, ensure MAC address and UUID are unique for each node.

```bash
# Check MAC address
ip a

# Example below,
link/ether 52:54:00:03:b4:f8 brd ff:ff:ff:ff:ff:ff
52:54:00:03:b4:f8 is mac address

# Check UUID
sudo cat /sys/class/dmi/id/product_uuid

# Finally, I am going to setup the hostnames.
Master -> k8s-master.lab.local
NodeA  -> k8s-worker1.lab.local
NodeB  -> k8s-worker2.lab.local

# You can do this with the following commands.

# On Master
sudo hostnamectl set-hostname k8s-master.lab.local

# On NodeA
sudo hostnamectl set-hostname k8s-worker1.lab.local

# On NodeB
sudo hostnamectl set-hostname k8s-worker2.lab.local
```

Then, change the /etc/hosts file on the `Master (control plane) only`

```bash
sudo vim /etc/hosts

# Paste this, change ips to whatever you use.
# K8 cluster nodes
10.1.30.10 k8s-master.lab.local
10.1.30.20 k8s-worker1.lab.local
10.1.30.21 k8s-worker2.lab.local

# While you are here, also change the 127.0.1.1 line at the top to reflect the hostnames we set above. For example,
127.0.1.1 k8s-master.lab.local
```

Load needed modules

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```

Reload system mods

```bash
sudo modprobe overlay
sudo modprobe br_netfilter
```

Configure kernel paremeters

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

Apply sysctl params without reboot

```bash
sudo sysctl --system
```

---

Install a container runtime, some options include docker engine, containerd, CRI-O. We will use containerd.

For future [reference](https://docs.docker.com/engine/install/ubuntu/)

Add Docker's official GPG key

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

Add the repository to Apt sources

```bash
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

Install latest version of `containerd.io`

```bash
sudo apt update && sudo apt install -y containerd.io
```

Configure `containerd` to use systemd as cgroup

```bash
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
```

Restart services

```bash
sudo systemctl restart containerd && sudo systemctl enable containerd
```

Install other kubeadm, kubelet and kubectl dependencies

```bash
sudo apt update && sudo apt install -y apt-transport-https ca-certificates curl gpg
```

Grab key

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

Add repo

```bash
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

Install kubeadm, kubelet and kubectl, marking it so it doesnt update.

```bash
sudo apt update && sudo apt install -y kubelet kubeadm kubectl && sudo apt-mark hold kubelet kubeadm kubectl
```

## Deploying the cluster

**Give it a good old reboot before this.**

ON THE `CONTROL PLANE`

Extremely important sidenote, this CIDR range **CANNOT** be in use on your network anywhere (accessible).

Initiate the cluster with a pod-network. Considerations here are that the `pod-network-cidr` cannot be in use in the network anywhere else. The `control-plane-endpoint` can be either the hostname or the IP of the control plane, but if you use hostname it must be resolvable by dns (On the local network or in their hosts file like we set above.)

```bash
sudo kubeadm init --pod-network-cidr=10.10.0.0/16 --control-plane-endpoint=<hostname>
```

You will get some output after this, make sure to keep the `token output and hash` so we can join nodes later.

```bash
...snip..
To start using your cluster, you need to run the following as a regular user:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
...snip...
```

This is based off what I was given as output, yours may be slightly different or the same, always double check.

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Test it is working with

```bash
kubectl cluster-info
```

**Side-note, I got an error about not being able to retrieve from port 8433. This was because when I did**

```bash
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# It prompted for
cp: overwrite '/home/alex/.kube/config'?
# You must type y, you cant just press enter.
```

#### Joining Worker Nodes

If you already have the join node output copied, skip the next 3 commands (Go to "Once you have all this ...").

If you didnt copy the token before its fine, just run

```bash
kubeadm token list
```

If its been over 24 hours, or you for some reason dont have one, you can use this to create one.

```bash
kubeadm token create
```

To get the hash, you can run this.

```bash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
```

Once you have all this you can join the node with (Make sure to use sudo)

```bash
sudo kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
```

For example,

```bash
sudo kubeadm join --token mediumlongtoken k8s-master.lab.local:6443 --discovery-token-ca-cert-hash sha256:reallylonghash
```

Test your creation

```bash
kubectl get nodes
```

> You will notice it says `NotReady` for all 3, this is because we do not have a `CNI (Container Network Interface)` setup for the cluster. As a quick info sess, CNI handles the Pod-to-Pod communication. Read more [here](https://kubernetes.io/docs/concepts/services-networking/).

## Resources

[video](https://www.youtube.com/watch?v=iwlNCePWiw4)

[guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)