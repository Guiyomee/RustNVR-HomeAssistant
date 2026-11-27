# The Docker image of RustNVR of the same version, with the start script of
# the app on top (nothing is compiled on the Home Assistant machine). Set
# here: the Supervisor warns that build.yaml is deprecated.
ARG BUILD_FROM=ghcr.io/guiyomee/rustnvr:2026.11.11
FROM ${BUILD_FROM}

# The start script reads the options of the app (jq) and the broker of Home
# Assistant (curl), as root, then starts RustNVR as its own account.
USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq curl \
    && rm -rf /var/lib/apt/lists/*
COPY run.sh /usr/local/bin/rustnvr-haos
RUN chmod 0755 /usr/local/bin/rustnvr-haos

ENTRYPOINT ["/usr/local/bin/rustnvr-haos"]
CMD []
