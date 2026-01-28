FROM quay.io/toolbx/ubuntu-toolbox:latest

ARG OPENCODE_VERSION=v1.1.36
ARG OPENCHAMBER_VERSION=v1.5.8

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash -

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

WORKDIR "$HOME"

# Install bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH=$HOME/.bun/bin:$PATH

# Install opencode
RUN curl -fsSL https://opencode.ai/install | bash -s -- --version "$OPENCODE_VERSION"
ENV PATH=$HOME/.opencode/bin:$PATH
RUN opencode --version

# Install openchamber
RUN bun install -g "@openchamber/web@$OPENCHAMBER_VERSION"

# Create persistent data directory
RUN sudo mkdir -p /data && \
    sudo chown -R opencode:opencode /data && \
    mkdir -p /data/opencode/config && \
    mkdir -p /data/opencode/storage && \
    echo '{}' > /data/opencode/auth.json && \
    ln -sf /data/opencode/config "$HOME/.config/opencode" && \
    ln -sf /data/opencode/storage "$HOME/.local/share/opencode/storage" && \
    ln -sf /data/opencode/auth.json "$HOME/.local/share/opencode/auth.json"

WORKDIR "$HOME/workspace"

EXPOSE 3000

ENTRYPOINT ["openchamber", "--port", "3000"]
