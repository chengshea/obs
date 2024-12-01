FROM debian:stretch-slim

RUN groupadd prometheus &&\
    useradd prometheusbeat &&\
    mkdir /data

COPY prometheusbeat /
COPY prometheusbeat.yml /
RUN chown prometheusbeat. /prometheusbeat /prometheusbeat.yml /data

USER prometheusbeat

ENTRYPOINT ["/prometheusbeat"]

CMD ["-e", "-c", "prometheusbeat.yml"]

#docker build -f ./Dockerfile  -t prometheusbeat:7.3.1 .
