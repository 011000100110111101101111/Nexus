# Deploying x

[toc]

## General Information

### Open Ports

## Known Requirements

Either deployment of a mongodb database outside, or using their attached mongodb inside the helm chart.

If doing manually, you need to set up a mongodb instance for it.

## Installation

```bash
helm repo add rocketchat https://rocketchat.github.io/helm-charts

helm install rocketchat -f values.yml rocketchat/rocketchat
```

## Troubleshooting commands

## Troubleshooting Topics

### Mongo DB Requires avx instructions for CPU

You may run into an issue where you get the following error,

```bash
mongodb 22:37:06.36 INFO  ==> Deploying MongoDB from scratch...
/opt/bitnami/scripts/libos.sh: line 346:    81 Illegal instruction     (core dumped) "$@" > /dev/null 2>&1
```

This is due to the cpu missing the avx instructions. You can check this with the following, (No output means you cannot support it)

```bash
cat /proc/cpuinfo | grep avx
```

## Resources