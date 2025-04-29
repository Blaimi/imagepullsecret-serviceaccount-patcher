FROM docker.io/library/golang:1.24.2 AS builder
WORKDIR /src

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY ./ /src
RUN CGO_ENABLED=0 GOOS=linux go build -o ./dist/ips-sa-p .

FROM scratch AS runtime

LABEL org.opencontainers.image.source = "https://github.com/Blaimi/imagepullsecret-serviceaccount-patcher"

COPY --from=builder /src/dist/ips-sa-p /ips-sa-p
ENTRYPOINT [ "/ips-sa-p" ]
