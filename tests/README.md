# Run some tests
* create the certificates
  ```shell
  (cd ssl; ./createcert.sh)
  ```
* create an htauth-file
  ```shell
  mkdir auth
  podman run --entrypoint htpasswd docker.io/library/httpd:2 -Bbn testuser testpassword > auth/htpasswd
  ```
* run a registry
  ```shell
  podman run -d -p 5000:5000 --name registry \
  -v $PWD/auth:/auth \
  -e REGISTRY_AUTH=htpasswd \
  -e REGISTRY_AUTH_HTPASSWD_REALM=Registry \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -v $PWD/ssl/:/ssl \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/ssl/certs.d/host.containers.internal_5000_/registry.crt \
  -e REGISTRY_HTTP_TLS_KEY=/ssl/registry.key \
  docker.io/library/registry:3
  ```
* create the kind cluster
  ```shell
  systemd-run --scope --property=Delegate=yes --user kind create cluster --config <(envsubst < kind-cluster-config.yaml)
  ```
* login to the registry
  ```shell
  echo testpassword | skopeo login --tls-verify=false --username testuser --password-stdin localhost:5000
  ```
* copy an image to the registry
  ```shell
  skopeo copy --dest-tls-verify=false docker://docker.io/library/busybox:latest docker://localhost:5000/busybox:latest
  ```
* try to run the image on the cluster
  ```shell
  kubectl run --image host.containers.internal:5000/busybox busybox -- sleep 2147483647
  ```
* see how the pod fails
  ```shell
  sleep 10
  STATUS=$(kubectl get pod busybox -o jsonpath='{.status.containerStatuses[0].state.waiting.reason}' || echo "Unknown")
  if [[ "$STATUS" != "ImagePullBackOff" && "$STATUS" != "ErrImagePull" ]]; then
    echo "Expected image pull to fail, but got: $STATUS"
    exit 1
  fi
  echo "Confirmed pod failed to pull image: $STATUS"
  ```
* install the [examples](../examples)
  ```shell
  kubectl apply -k ../examples
  kubectl rollout status -n kube-system deployment.apps/imagepullsecret-serviceaccount-patcher --timeout=600s
  kubectl rollout status -n kube-system deployment.apps/replicator-kubernetes-replicator --timeout=600s
  ```
* recreate the pod
  ```shell
  kubectl delete pod nginx
  kubectl run --image host.containers.internal:5000/nginx nginx
  ```
* test for the running pod
  ```shell
  kubectl wait pod/busybox --for=condition=Ready --timeout=60s
  ```

# TODO
* make it in CI via [podman-kind](https://gitlab.com/podman-kind/podman-kind)
