#!/bin/sh


podman run --rm -v $PWD:/workdir --workdir=/workdir docker.io/alpine/openssl genrsa -out registry.key 2048

podman run --rm -v $PWD:/workdir --workdir=/workdir docker.io/alpine/openssl req -new -key registry.key -out "registry.csr" -subj "/CN=localhost" -config certconfig.ini

podman run --rm -v $PWD:/workdir --workdir=/workdir docker.io/alpine/openssl x509 -req -in registry.csr -signkey registry.key -out "registry.crt" -days 1 -extensions v3_req -extfile certconfig.ini

mv registry.crt "certs.d/host.containers.local:5000"
