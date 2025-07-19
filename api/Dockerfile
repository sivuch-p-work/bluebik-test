FROM golang:1.24.4-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o main

FROM alpine:3.19 AS final
WORKDIR /app
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]