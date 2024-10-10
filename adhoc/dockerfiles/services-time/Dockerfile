FROM alpine:latest
ARG VERSION=develop
LABEL org.opencontainers.image.title="Time Service"
LABEL org.opencontainers.image.vendor="Contoso, Inc"
LABEL org.opencontainers.image.version="$VERSION"
WORKDIR /opt/time-service
COPY ./dockerfiles/services-time/docker-entrypoint.sh /docker-entrypoint.sh
COPY ./artifacts/bin/services-time /opt/time-service/time-service
ENTRYPOINT [ "/docker-entrypoint.sh" ]
