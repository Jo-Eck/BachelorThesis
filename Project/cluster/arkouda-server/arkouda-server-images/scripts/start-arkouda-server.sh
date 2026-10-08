#!/bin/bash

service ssh start

mkdir ~/.ssh/
cp ~/ssh-keys/id_rsa* ~/.ssh/
chmod -R 600 ~/.ssh/*
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

export LOCALE_IPS="$(python3 /opt/arkouda-contrib/arkouda_integration/client/scripts/pods.py '-i=get_pod_ips' '--namespace=arkouda' '--app_name=arkouda-locale')"
export SSH_SERVERS="$MY_IP $LOCALE_IPS"

/opt/arkouda/arkouda_server -nl ${NUMLOCALES:-1} --ExternalIntegration.systemType=SystemType.KUBERNETES \
	                                         --ServerDaemon.daemonTypes=ServerDaemonType.INTEGRATION \
                                                 --memTrack=${MEMTRACK:-true} --authenticate=${AUTHENTICATE:-false} \
                                                 --logLevel=${LOG_LEVEL:-LogLevel.INFO}
