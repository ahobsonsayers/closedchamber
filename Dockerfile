FROM quay.io/toolbx/ubuntu-toolbox:latest

ARG APP=openchamber
ARG OPENCHAMBER_VERSION=v1.5.8
ARG OPENCODE_VERSION=v1.1.36

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

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

ENV HOME="/home/$APP"

RUN mkdir -p "$HOME" && \
    useradd -m -d "$HOME" "$APP" && \
    chown -R "$APP":"$APP" "$HOME"

RUN echo "$APP ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$APP && \
    chmod 0440 /etc/sudoers.d/$APP

WORKDIR "$HOME"
USER "$APP"

RUN curl -fsSL https://bun.sh/install | bash
ENV PATH=$HOME/.bun/bin:$PATH

RUN OPENCODE_VERSION=${OPENCODE_VERSION} curl -fsSL https://opencode.ai/install | bash
ENV PATH=$HOME/.opencode/bin:$PATH
RUN opencode --version

RUN bun install -g "@openchamber/web@$OPENCHAMBER_VERSION"

RUN sudo mkdir -p /persistence && \
    sudo chown -R $APP:$APP /persistence

RUN ln -sf /persistence/opencode/storage "$HOME/.local/share/opencode/storage" && \
    ln -sf /persistence/opencode/auth.json "$HOME/.local/share/opencode/auth.json" && \
    ln -sf /persistence/opencode/config "$HOME/.config/opencode"

WORKDIR "$HOME/workspace"

EXPOSE 3000

ENTRYPOINT ["openchamber", "--port", "3000"]