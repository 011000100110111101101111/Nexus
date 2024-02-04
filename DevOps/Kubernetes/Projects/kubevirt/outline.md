# Deploying kubevirt

[toc]

## General Information

Kubevirt operator gives the ability to deploy virtual machines via kubernetes

### Open Ports

## Known Requirements

## Installation

```bash
# Point at latest release
export RELEASE=$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
# Deploy the KubeVirt operator
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-operator.yaml
# Create the KubeVirt CR (instance deployment request) which triggers the actual installation
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-cr.yaml
# wait until all KubeVirt components are up
kubectl -n kubevirt wait kv kubevirt --for condition=Available
```

It also requires virtctl integration to interact with the commandline. We will install this as a plugin to kubectl using krew. First we must install krew.

```bash
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# Then export path
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
```

Now lets install virtctl

```bash
kubectl krew install virt
```

## Quickstart




## Troubleshooting commands

## Troubleshooting Topics


### Export issue
Exporting the release with the first command didnt work well. Just echo $RELEASE and manually place it if it doesnt work.

### KVM not supported for workers deployed on proxmox

In short, change cpu to HOST

[details here](https://pve.proxmox.com/wiki/Nested_Virtualization)



## Resources

[kubevirt install guide](https://kubevirt.io/user-guide/operations/installation/#installing-kubevirt-on-kubernetes)
[krew install](https://krew.sigs.k8s.io/docs/user-guide/setup/install/)

[Great Indepth Explanation of Kube-Virt](https://arthurchiao.art/blog/kubevirt-create-vm/)