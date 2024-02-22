---
layout: post
title: Kubernetes Longhorn Deployment Guide
date: 2024-02-16
summary: Covers deploying and setting up longhorn via helm or manually
categories: guides
---

**Guide results**

- This guide will cover deploying longhorn across all your nodes in the cluster, pooling their storage and allowing them to be accessible via a PVC. We can also set longhorn as the default storageclass, making helm installations extremely easy.

**Prerequisites / Important Information**

- Sidenote: Longhorn is a great solution when running a baremetal Kubernetes cluster and you want to have local storage available for all the nodes and useable by statefulsets (databases). However, it is not necessarily needed if you already have a NFS solution or some other provided csi, especially when in a cloud environment where you have access to more integrated storage solutions.
- The included file longhorn-ingress.yml is for the longhorn dashboard. The ingress is set up to use cert-manager via a clusterissuer.
- Base VMS/Machines MUST have enough space or you will run into disk pressure errors. I found 30GB free+ worked.
- If wanting to use UI dashboard requires ingress via port 80

### Installing via Helm

```bash
# Add longhorn Repo and update
helm repo add longhorn https://charts.longhorn.io
helm repo update

# Install longhorn in its own namespace
LONVER=$(curl -s https://api.github.com/repos/longhorn/longhorn/releases/latest|grep tag_name|cut -d '"' -f 4)
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version $LONVER

# Check success
kubectl -n longhorn-system get pod
```

### Installing Manually

```bash
# Apply the manifest
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.5.3/deploy/longhorn.yaml

# Or if you want to look at it before applying
LONVER=$(curl -s https://api.github.com/repos/longhorn/longhorn/releases/latest|grep tag_name|cut -d '"' -f 4)
wget https://raw.githubusercontent.com/longhorn/longhorn/${LONVER}/deploy/longhorn.yaml
kubectl apply -f longhorn.yaml

# Check success
kubectl get pods --namespace longhorn-system --watch
```

### (Optional) Setting longhorn as default CSI

```bash
# TO mark it as default
kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# TO unmark it as default
kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

### (Optional) Example ingress for web UI

This example ingress is using nginx ingress controller and cert-manager. It will provide basic authentication (Username and password popup) and tls. This assumes you have already configured cert-manager, nginx ingress controller, and your DNS provider to handle wildcard subdomains \*.example.com.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: longhorn-ingress
  namespace: longhorn-system
  annotations:
    # type of authentication
    nginx.ingress.kubernetes.io/auth-type: basic
    # prevent the controller from redirecting (308) to HTTPS
    kubernetes.io/ingress.allow-http: "false"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    # name of the secret that contains the user/password definitions
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    # message to display with an appropriate context why the authentication is required
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required "
    # custom max body size for file uploading like backing image uploading
    nginx.ingress.kubernetes.io/proxy-body-size: 10000m
    # Certmanager
    cert-manager.io/cluster-issuer: "development-issuer"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - longhorn.example.com
      secretName: longhorn-ui-tls
  rules:
    - host: longhorn.example.com
      http:
        paths:
          - pathType: Prefix
            path: "/"
            backend:
              service:
                name: longhorn-frontend
                port:
                  number: 80
```

### Testing

To test this, create a PVC using the storageClassName longhorn.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
name: pihole-etc-longhorn-claim
namespace: homelab
spec:
storageClassName: longhorn
accessModes:
  - ReadWriteOnce
resources:
  requests:
  storage: 5Gi
```

Then, claim it for a deployment under volumes,

```yaml
spec:
replicas: 1
selector:
    matchLabels:
    app: pihole
template:
    metadata:
    labels:
        app: pihole
    spec:
    containers:
    - name: pihole
        image: pihole/pihole:latest
        ...
        volumeMounts:
        - name: etc
        mountPath: "/etc/pihole"
        - name: dnsmasq
        mountPath: "/etc/dnsmasq.d"
    volumes:
        - name: etc
        persistentVolumeClaim:
            claimName: pihole-etc-longhorn-claim
        - name: dnsmasq
        persistentVolumeClaim:
            claimName: pihole-dnsmasq-longhorn-claim
```
