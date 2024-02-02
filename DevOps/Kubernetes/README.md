# Current Kubernetes Infastructure


## IPS / Domains

[hosts]
- k8-master-1
  - 192.168.3.200
- k8-worker-1
  - 192.168.3.210
- k8-worker-2
  - 192.168.3.211
- k8-nfs-share
  - 192.168.3.212

[network]
- k8 subnet
  - 10.90.0.0/16
- metallb balancer range
  - 192.168.3.220-192.168.3.230

## Core Services / Plugins

- Ingress
  - [nginx-ingress-controller](https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-helm/)
- Loadbalancer
  - [metallb](https://metallb.org/installation/)
- CNI
  - [flannel](https://github.com/flannel-io/flannel)
- CSI
  - [csi-driver-nfs](https://github.com/kubernetes-csi/csi-driver-nfs/tree/master/charts)


## Deployed Applications

- Gitlab
  - http://192.168.3.221:8080
  - Also, 22, and 443
- postgressql
  - Internal, 5432
- HAProxy Ingress
  - 80, 443, 5432

