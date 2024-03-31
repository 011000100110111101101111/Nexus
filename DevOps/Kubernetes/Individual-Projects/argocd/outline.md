# Deploying argocd

[toc]

## General Information

### Open Ports

## Known Requirements

## Installation

You can directly install everything or download it first then apply it

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

If you are not interested in UI, SSO, multi-cluster features then you can install core Argo CD components only:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml
```

Now install argocd cml tool

For linux
`
```bash
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64
```

For Mac

```bash
brew install argocd
```

### Access argocd API server

You have 3 options.

For loadbalancer

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

For Ingress with ingress-nginx (further documentation [here](https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/))

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    # If using certmanager
    # Used to provide wildcard domain prefixs to base domain
    kubernetes.io/tls-acme: "true"
    # This is clusterissuer you set up with cert-manager
    cert-manager.io/cluster-issuer: development-issuer
    # Disable http
    kubernetes.io/ingress.allow-http: "false"
    # Default
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    # I needed to add this for it to work
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  ingressClassName: nginx
  rules:
  - host: argocd.<domain>
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              name: https
  tls:
    - hosts:
      - argocd.<domain>
      secretName: argocd-server-tls # as expected by argocd-server
```

For Portforwarding

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Logging in

You can now access the web UI at the ingress you created.

However, we are going to use the argocd cli for some steps now.

First, get the initial password

```bash
argocd admin initial-password -n argocd
```

Then login to server

```bash
argocd login <ARGOCD_SERVER>

# you can either do the ingress directly
argocd login argocd.<domain>

# or you can do the IP you exposed
argocd login <ip>
```

Now, change the password

```bash
argocd account update-password
```

### Registering Cluster (Optional, for external cluster not running argocd)

```bash
kubectl config get-contexts -o name

$ output@output

argocd cluster add <output@output>
```

### Creating apps via CLI

```bash
# Needs to be in argocd idk
kubectl config set-context --current --namespace=argocd
# Example one
argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default

# Then sync it
argocd app get guestbook
```

### Creating apps via UI

Go to UI and follow [Step 6 Creating Apps Via UI](https://argo-cd.readthedocs.io/en/stable/getting_started/)

## Troubleshooting commands

## Troubleshooting Topics

## Resources
