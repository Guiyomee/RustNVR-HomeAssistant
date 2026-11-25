# Multi-arch base image (amd64, aarch64), set here: the Supervisor warns
# that build.yaml is deprecated, and no longer passes BUILD_FROM since 2026.04.
ARG BUILD_FROM=ghcr.io/home-assistant/base:3.22
FROM ${BUILD_FROM}

RUN apk add --no-cache nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
