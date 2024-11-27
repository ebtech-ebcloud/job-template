

## kubectl
> we only prepared files for linux x86-64 arch.

downloaded from kubernetes.io:

https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/


> curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl
> curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl.sha256


Validate the binary:
```
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
```

install to system:
```
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

```

validate version:
```
kubectl version --client
```
