# Deploying x

[toc]

## General Information

Reasing behind using a stateful set for db over a typical deployment. [Source](https://devopscube.com/deploy-mongodb-kubernetes/)

    A deployment is a Kubernetes object which is preferred when deploying a stateless application or when multiple replicas of pods can use the same volume.

    A stateful set is a Kubernetes object which is preferred when we require each pod to have its own independent state and use its own individual volume.

    Another major difference between them is the naming convention for pods. In the case of deployments, pods are always assigned a unique name but this unique name changes after the pod are deleted & recreated.

    In the case of the stateful set – each pod is assigned a unique name and this unique name stays with it even if the pod is deleted & recreated.

    Let's take an example of mongodb to understand the difference better.

    Case of deployments: name of pod initially: mongo-bcr25qd41c-skxpe  
    name of pod after it gets deleted & recreated: mongo-j545c6dfk4-56fcs 
    Here, pod name got changed.

    Case of statefulsets: name of pod initially: mongo-0 
    name of pod after it gets deleted & recreated: mongo-0 Here, pod name remained the same.

### Open Ports

## Known Requirements

## Installation

### Manual

Ensure you are in the correct namespace, or supply the namespace you want for each command with -n <namespace>

```bash
# Create the login
kubectl create secret generic mongo-creds --from-literal=password=password123 --from-literal=username=admin

kubectl apply -f deployment.yml
```

## Troubleshooting commands

## Troubleshooting Topics

## Resources