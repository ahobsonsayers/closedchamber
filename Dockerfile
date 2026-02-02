FROM arranhs/closedcode:1.1.48

ARG OPENCHAMBER_VERSION=1.6.2

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 && \
    rm -rf /var/lib/apt/lists/*

USER opencode

RUN bun install -g @openchamber/web@$OPENCHAMBER_VERSION

ENTRYPOINT ["/entrypoint.sh", "bun", "run", "@openchamber/web"]