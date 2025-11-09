#!/bin/bash
sudo mkdir -p /run/sshd
sudo ssh-keygen -A
mkdir -p ~/.ssh
chmod 600 ~/.ssh/authorized_keys
if test -n "$AUTHORIZED_KEY"
then echo "$AUTHORIZED_KEY" >>~/.ssh/authorized_keys
fi
ln -sf /workspace ~/workspace
sudo chown -R 1000:1000 /workspace
