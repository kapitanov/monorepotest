FROM alpine:latest
ARG VERSION=develop
LABEL org.opencontainers.image.title="Date Service"
LABEL org.opencontainers.image.vendor="Contoso, Inc"
LABEL org.opencontainers.image.version="$VERSION"
WORKDIR /opt/date-service
COPY ./dockerfiles/services-date/docker-entrypoint.sh /docker-entrypoint.sh
COPY ./artifacts/bin/services-date /opt/date-service/date-service
ENTRYPOINT [ "/docker-entrypoint.sh" ]
