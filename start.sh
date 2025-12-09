#!/bin/bash

# setup sshd keys
mkdir -p /run/sshd
ssh-keygen -A

# update ops
export HOME=/home
export OPS_HOME=/home
ops -update


# setup user workspace
if test -z "$USERID"
then USERID=1000
fi
/usr/sbin/useradd -u "$USERID" -d $HOME -o -U -s /bin/bash devel 2>/dev/null

# add ssh key
if test -n "$SSHKEY"
then
    mkdir -p $HOME/.ssh
    touch $HOME/.ssh/authorized_keys
    if ! grep "$SSHKEY" $HOME/.ssh/authorized_keys >/dev/null
    then echo "$SSHKEY" >>$HOME/.ssh/authorized_keys
    fi
    chmod 600 $HOME/.ssh/authorized_keys
    chmod 700 $HOME/.ssh
fi

# intialize
cd /home/app
uv sync
cd /home/workspace
# add env vars to allow ops ide login and vite proxy
printf "OPS_APIHOST=http://miniops.me\nOPS_USER=devel\nOPS_PASSWORD=$OPS_PASSWORD\nOPS_HOST=http://devel.miniops.me\n" >".env"

# fix permissions
chmod 0755 $HOME
chown -Rf "$USERID" /home

# start supervisor
exec supervisord -c /home/supervisord.ini
