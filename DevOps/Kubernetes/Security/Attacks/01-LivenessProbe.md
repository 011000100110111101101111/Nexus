# Attack 01 - Liveness Probe

## Description

This attack can mostly be used to maintain persistence inside a pod incase someone manually goes in and disables your attack vector.

## Use Case

Kubernetes pods can be made to perform a liveness check which is meant to be used to ensure the pod is running correctly. If the liveness probe fails, the pod is restarted to its original state. This can be extremely useful in certain cases, lets outline a few.

Example 1: Web UI Persistence

You have deployed a web application with a login. The use goes to this web server, and in an attempt to secure it changes the default password. However, your liveness probe is checking the internal files for the container running the webserver and seeing if the password is still the default password. When this fails, it restarts the web server, essentially removing the ability to lock it down.

## Implementation

It can really be as simple as this,

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: nginx
  name: nginx-probe
spec:
  containers:
  - name: nginx-probe
    image: nginx
    livenessProbe:
      exec:
        command:
        - sh
        - -c
        - | -
          used=$(awk '{ print int($1/1.049e+6) }' /sys/fs/cgroup/memory/memory.usage_in_bytes);
          thresh=$(awk '{ print int( $1 / 1.049e+6 * 0.9 ) }' /sys/fs/cgroup/memory/memory.limit_in_bytes);
          health=$(curl -s -o /dev/null --write-out "%{http_code}" http://localhost:8080/health);
          if [[ ${used} -gt ${thresh} || ${health} -ne 200 ]]; then exit 1; fi
```

TODO: Continue attack 01, change command to check /etc/passwd entry
