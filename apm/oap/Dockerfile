#alpine 包含busybox
#FROM alpine:latest

FROM busybox:stable

#curl
FROM tools:cs

WORKDIR /app
COPY ./thanos-remote-read .

EXPOSE 10080

ENTRYPOINT ["/app/thanos-remote-read"]

