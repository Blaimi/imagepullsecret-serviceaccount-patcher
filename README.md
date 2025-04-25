# ImagePullSecret Service Account Patcher

Simple Go application that takes to the Kubernetes API to add (multiple) `ImagePullSecrets` to all 
ServiceAccounts in the cluster. 

## Motivation
This project was started because of the issue that credentials to private container registry cannot be
provided on a clusterwide level (cf. [stackoverflow issue](https://stackoverflow.com/questions/52320090/automatically-add-imagepullsecrets-to-a-serviceaccount)).
Others suggested manually pulling images to your nodes, patching Service Accounts manually or adapting the `docker/config.json`
of each cluster's node (cf. [here](https://stackoverflow.com/a/55230340/5930295)).

This project was inspired by [titansoft-pte-ltd/imagepullsecret-patcher](https://github.com/titansoft-pte-ltd/imagepullsecret-patcher) 
which, however, only allows to add one private container registry secret to the cluster's service accounts.

## Usage
It is at best used in conjunction with [mittwald/kubernetes-replicator](https://github.com/mittwald/kubernetes-replicator).
Thus this is the complete approach:

Edit the files in [./examples](examples) to your needs
```bash
kubectl apply -k examples
```

## Build
```bash
docker buildx build . -t ghcr.io/blaimi/imagepullsecret-serviceaccount-patcher:local-dev --platform linux/amd64,linux/arm64 --no-cache
```
