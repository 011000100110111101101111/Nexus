# Deploying tailscale operator

[toc]

## General Information

Tailscale operator allows exposing services directly to your tailscale network by adding annotations to the services

### Open Ports


## Known Requirements

You need to do the initial setup on your tailscale account by adding the following

```yaml
"tagOwners": {
   "tag:k8s-operator": [],
   "tag:k8s": ["tag:k8s-operator"],
}
```
inside of your tailnet policy file.

Then, you need to create an oauth credential

admin console -> settings -> generate oath client -> write for devices -> k8s:operator tag

And use the client id and secret for the following steps.

## Installation

Specific install directions [here](https://tailscale.com/kb/1236/kubernetes-operator)

```bash
# Add the repo
helm repo add tailscale https://pkgs.tailscale.com/helmcharts
helm repo update
helm upgrade \
  --install \
  tailscale-operator \
  tailscale/tailscale-operator \
  --namespace=tailscale \
  --create-namespace \
  --set-string oauth.clientId=<OAauth client ID> \
  --set-string oauth.clientSecret=<OAuth client secret> \
  --wait
```
## Troubleshooting commands

## Troubleshooting Topics

## Resources