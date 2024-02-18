---
layout: post
title: Kubernetes cluster on LXC Deployment Guide
date: 2024-02-16
summary: Covers deploying a Kubernetes cluster to an existing LXC cluster.
categories: orchestration kubernetes
---

**Guide results**

- Kubernetes cluster deployed inside LXC containers

**Prerequisites**

- Everything is done on Ubuntu 22.04 LTS server.
- You must have atleast 2 nodes.
- You already deployed an LXC cluster. See my LXC guide first if you have not.

---

LXC by default does not allow docker / containerd to run inside, we need to add specific flags to allow this. We are going to do this by creating a seperate profile so we dont need to add to the command line every time.

```bash
# Check current ones
lxc profile list
# Copy default to k8s-config
lxc profile copy default k8s-config
# Edit the config and enter information below
lxc profile edit k8s-config
```

```yaml
config:
  limits.cpu: "2"
  limits.memory: 2GB
  limits.memory.swap: "false"
  linux.kernel_modules: ip_tables,ip6_tables,nf_nat,overlay,br_netfilter
  raw.lxc: "lxc.apparmor.profile=unconfined\nlxc.cap.drop= \nlxc.cgroup.devices.allow=a\nlxc.mount.auto=proc:rw sys:rw"
  security.nesting: "true"
  security.privileged: "true"
description: LXD profile for Kubernetes
devices:
  eth0:
    name: eth0
    nictype: macvlan
    parent: ens18
    type: nic
  root:
    path: /
    pool: remote
    type: disk
name: k8s-config
used_by: []                                                                                                                                                             /0.1s
```

Now we can create an `Ubuntu 22.04` image using this new profile

```bash
# Launch via the profile
lxc launch images:ubuntu/22.04 k8-master --profile k8s-config

# Check it
lxc list
```

We need to run the following command on the `lxc host` machine (The one running lxc, not the containers themselves) to allow kube-proxy to function correctly.

**Since you are in a cluster, you need to run this on any machine that you may deploy the cluster machines too**

```bash
sudo sysctl -w net.netfilter.nf_conntrack_max=524288
```

Now, we will use the following bootstrap script from [here](https://github.com/justmeandopensource/kubernetes/blob/master/lxd-provisioning/) with some of my own alterations.

```bash
#!/bin/bash

# This script has been tested on Ubuntu 22.04
# For other versions of Ubuntu, you might need some tweaking

echo "[TASK 1] Install essential packages"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null
apt-get install -qq -y net-tools curl ssh software-properties-common >/dev/null

echo "[TASK 2] Install containerd runtime"
apt-get install -qq -y apt-transport-https ca-certificates curl gnupg lsb-release >/dev/null
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update -qq >/dev/null
apt-get install -qq -y containerd.io >/dev/null
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd >/dev/null

echo "[TASK 3] Set up kubernetes repo"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' > /etc/apt/sources.list.d/kubernetes.list

echo "[TASK 4] Install Kubernetes components (kubeadm, kubelet and kubectl)"
apt-get update -qq >/dev/null
apt-get install -qq -y kubeadm kubelet kubectl >/dev/null
echo 'KUBELET_EXTRA_ARGS="--fail-swap-on=false"' > /etc/default/kubelet
systemctl restart kubelet

echo "[TASK 5] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo "[TASK 6] Set root password"
echo -e "kubeadmin\nkubeadmin" | passwd root >/dev/null 2>&1
echo "export TERM=xterm" >> /etc/bash.bashrc

#######################################
# To be executed only on master nodes #
#######################################

if [[ $(hostname) =~ .*master.* ]]
then

  echo "[TASK 7] Pull required containers"
  kubeadm config images pull >/dev/null 2>&1

  echo "[TASK 8] Initialize Kubernetes Cluster"
  kubeadm init --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=all >> /root/kubeinit.log 2>&1

  echo "[TASK 9] Copy kube admin config to root user .kube directory"
  mkdir /root/.kube
  cp /etc/kubernetes/admin.conf /root/.kube/config

  echo "[TASK 10] Deploy Calico network"

  kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

  echo "[TASK 11] Generate and save cluster join command to /joincluster.sh"
  joinCommand=$(kubeadm token create --print-join-command 2>/dev/null)
  echo "$joinCommand --ignore-preflight-errors=all" > /joincluster.sh

fi

#######################################
# To be executed only on worker nodes #
#######################################

if [[ $(hostname) =~ .*worker.* ]]
then
  echo "[TASK 7] Join node to Kubernetes Cluster"
  apt install -qq -y sshpass >/dev/null 2>&1
  sshpass -p "kubeadmin" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no kmaster.lxd:/joincluster.sh /joincluster.sh 2>/tmp/joincluster.log
  bash /joincluster.sh >> /tmp/joincluster.log 2>&1
fi
```
