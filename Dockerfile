FROM arranhs/closedcode:1.1.48

ARG OPENCHAMBER_VERSION=1.6.2

RUN bun install -g @openchamber/web@$OPENCHAMBER_VERSION

ENTRYPOINT ["/entrypoint.sh", "bun", "run", "@openchamber/web"]