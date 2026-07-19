FROM golang:1.26-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /mwendo-backend ./cmd/api

FROM alpine:latest
WORKDIR /
COPY --from=builder /mwendo-backend /mwendo-backend
EXPOSE 8080
ENTRYPOINT ["/mwendo-backend"]
