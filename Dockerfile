FROM quay.io/toolbx/ubuntu-toolbox:latest

ARG OPENCODE_VERSION=v1.1.36
ARG OPENCHAMBER_VERSION=v1.5.8

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    ca-certificates \
    coreutils \
    curl \
    dpkg \
    findutils \
    git \
    grep \
    jq \
    nodejs \
    sed \
    sudo \
    unzip \
    util-linux \
    wget

ENV HOME="/home/opencode"

# Create opencode user
# User will have root access via sudo
RUN useradd opencode --uid 1000 --home-dir "$HOME" --create-home && \
    echo "opencode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/opencode && \
    chmod 0440 /etc/sudoers.d/opencode

USER opencode

# Install bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH=$HOME/.bun/bin:$PATH

# Install opencode
RUN bun add -g opencode-ai@$OPENCODE_VERSION

# Install openchamber
RUN bun add -g @openchamber/web@$OPENCHAMBER_VERSION

# Persistence
VOLUME /home/opencode/.config/opencode # Persist opencode config
VOLUME /home/opencode/.local/share/opencode # Persist opencode sessions

WORKDIR "$HOME/workspace"

EXPOSE 3000

ENTRYPOINT ["openchamber", "--port", "3000"]

