FROM busybox:stable


WORKDIR /app

#go install github.com/G-Research/thanos-remote-read@latest
COPY ./thanos-remote-read .

EXPOSE 10080

ENTRYPOINT ["/app/thanos-remote-read"]

#docker build -f ./Dockerfile  -t thanos-remote-read:latest .
