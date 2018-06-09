#!/bin/sh
break>/etc/docker/daemon.json
echo '{' >> /etc/docker/daemon.json
echo '  "debug": true,' >> /etc/docker/daemon.json
echo '  "tls": true,'>> /etc/docker/daemon.json
echo '  "tlscacert": "/home/vagrant/ca.pem",'>> /etc/docker/daemon.json
echo '  "tlscert": "/home/vagrant/cert.pem",'>> /etc/docker/daemon.json
echo '  "tlskey": "/home/vagrant/key.pem",'>> /etc/docker/daemon.json
echo '  "hosts": ["tcp://10.11.1.41:2376"],'>> /etc/docker/daemon.json
echo '  "tlsverify": true'>> /etc/docker/daemon.json
echo '}' >> /etc/docker/daemon.json
echo "daemon.json created in /etc/docker/"