# Run some tests
* create the certificates
  ```shell
  (cd ssl; ./createcert.sh)
  ```
* run a registry
  ```shell
  podman run -d -p 5000:5000 --name registry -v $PWD:/certs -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key registry:3
  ```
* create the kind cluster
  ```shell
  systemd-run --scope --property=Delegate=yes --user kind create cluster --config kind-cluster-config.yaml
  ```
* copy an image to the registry
  ```shell
  skopeo copy --dest-tls-verify=false docker://docker.io/library/nginx:latest docker://localhost:5000/nginx:latest
  ```
* run the image on the cluster
  ```shell
  kubectl run --image host.containers.internal:5000/nginx nginx
  ```

# TODO
* restrict the access to the registry by requiring authentication with [basic-auth](https://distribution.github.io/distribution/about/deploying/#restricting-access)
* install ips-sa-p
* check the events of the pods to have proof that it only works with ips-sa-p set up
* make it in CI via [podman-kind](https://gitlab.com/podman-kind/podman-kind)
