#!/bin/bash

#setup sshd
mkdir -p /run/sshd
ssh-keygen -A

export PORT1=${SSH_PORT:-2222}
export PORT2=${OPENCODE_PORT:-2223}

# setup user
export HOME=/home
if test -n "$USERID"
then
    useradd -u "$USERID" -d /home -o -U user -s /bin/bash
    ops -update
    git clone https://github.com/apache/openserverless-devcontainer $HOME/.ops/openserverless-devcontainer
    ln -sf  $HOME/.ops/openserverless-devcontainer/olaris-tk $HOME/.ops/olaris-tk

    if test -n "$SSHKEY"
    then
        mkdir -p $HOME/.ssh
        echo "$SSHKEY" >>$HOME/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
    fi
    chown -Rvf "$USERID" /home
fi
cd /workspace
echo Starting ssh in port $PORT1 and opencode in $PORT2 for user $USERID
concurrently \
 "sudo /usr/sbin/sshd -p $PORT1 -D" \
 "opencode serve -p $PORT2 --hostname 0.0.0.0"

