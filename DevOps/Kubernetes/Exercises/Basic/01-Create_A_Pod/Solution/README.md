# Solution

Here is an example yaml file for a simple pod running nginx.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
```

This can then be applied to the cluster with,

```bash
kubectl apply -f file.yaml
```
