FROM debian:bookworm AS pgloader-builder

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl sbcl make unzip ca-certificates  \
    libsqlite3-dev libssl-dev gawk freetds-dev jq \
    && rm -rf /var/lib/apt/lists/*

# build opencode
WORKDIR /
RUN curl -fsSL https://bun.com/install |  bash -s -- bun-v1.3.3
ENV PATH=/root/.bun/bin:/bin:/usr/bin
RUN \
   git clone https://github.com/sst/opencode && \
   cd /opencode && bun install && ./packages/opencode/script/build.ts --single && \
   mv -v ./packages/opencode/dist/opencode-linux-$(dpkg --print-architecture)/bin/opencode /usr/bin/opencode

# build pgloader
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
    locales postgresql-client-16 openssh-server tini supervisor

# setup env
RUN \
    touch /.dockerenv && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8
RUN userdel node ; rm -Rvf /home/node

# env vars
ENV OPS_HOME=/home
ENV OPS_REPO=https://github.com/nuvolaris/bestia
ENV OPS_BRANCH=bestia
ENV PATH=/home/.opencode/bin:/home/.local/bin:/home/.bun/bin:/usr/local/bin:/usr/bin:/bin
ENV HOME=/home
RUN printf "OPS_HOME=$OPS_HOME\nOPS_BRANCH=$OPS_BRANCH\nPATH=$PATH\nOPS_REPO=https://github.com/nuvolaris/bestia\n" >/etc/environment
RUN printf "export OPS_HOME=$OPS_HOME\nexport OPS_BRANCH=$OPS_BRANCH\nexport PATH=$PATH\nexport OPS_REPO=https://github.com/nuvolaris/bestia\n" >>/etc/profile

# pgloader, uv, bun, opencode
COPY --from=pgloader-builder /build/pgloader/build/bin/pgloader /usr/bin/pgloader
COPY --from=pgloader-builder /usr/bin/opencode /usr/bin/opencode
COPY --from=pgloader-builder /root/.bun/bin/bun /usr/bin/bun

RUN \
    curl -LsSf https://astral.sh/uv/install.sh | sh
RUN \
    npm install -g npm
RUN \
    curl -sL https://raw.githubusercontent.com/apache/openserverless-cli/refs/heads/main/install.sh | bash ;\
    ops -t ;\
    git clone https://github.com/apache/openserverless-devcontainer $HOME/.ops/openserverless-devcontainer ;\
    ln -sf  $HOME/.ops/openserverless-devcontainer/olaris-tk $HOME/.ops/olaris-tk


ADD start.sh /home/start.sh
ADD opsdevel.sh /home/opsdevel.sh
ADD opencode.sh /home/opencode.sh
ADD supervisord.ini /home/supervisord.ini
ADD opencode.json /home/.config/opencode/opencode.json

ADD workspace /home/workspace
ADD app /home/app
WORKDIR /home/workspace
RUN npm install
ENTRYPOINT ["tini", "--"]
CMD ["/home/start.sh"]
