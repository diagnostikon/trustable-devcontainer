FROM debian:bookworm AS pgloader-builder

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl sbcl make unzip ca-certificates \
    libsqlite3-dev libssl-dev gawk freetds-dev jq \
    && rm -rf /var/lib/apt/lists/*

# Clone pgloader and build it
WORKDIR /build
RUN git clone https://github.com/dimitri/pgloader.git \
    && cd pgloader \
    && make

FROM node:22
# Install basic development tools
RUN \
    echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc |  apt-key add - && \
    apt update && \
    apt install -y less man-db sudo vim jq python-is-python3 python3-virtualenv \
    locales postgresql-client-16 openssh-server

RUN \
    touch /.dockerenv && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale ANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Ensure default `node` user has access to `sudo`
ARG USERNAME=node
RUN \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# install ops and plugins
USER node
RUN \
    curl -sL https://raw.githubusercontent.com/apache/openserverless-cli/refs/heads/main/install.sh | bash
RUN \
    curl -LsSf https://astral.sh/uv/install.sh | sh

ENV PATH="/home/node/.local/bin:${PATH}"

RUN \
    ops -update
RUN \
    git clone https://github.com/apache/openserverless-devcontainer /home/node/.ops/openserverless-devcontainer ;\
    ln -sf  /home/node/.ops/devcontaine/olaris-tk /home/node/olaris-tk

COPY --from=pgloader-builder /build/pgloader/build/bin/pgloader /usr/bin/pgloader
ADD start-ssh.sh /start-ssh.sh

CMD ["/start-ssh.sh"]
