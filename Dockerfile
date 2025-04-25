FROM docker.io/library/golang:1.24.2 AS builder
WORKDIR /src

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY ./ /src
RUN CGO_ENABLED=0 GOOS=linux go build -o ./dist/app .

FROM scratch AS runtime
COPY --from=builder /src/dist/app /app
ENTRYPOINT /app
