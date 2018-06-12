#!/bin/sh
break>/etc/systemd/system/docker.service.d/override.conf
echo '[Service]' >> /etc/systemd/system/docker.service.d/override.conf
echo 'ExecStart=' >> /etc/systemd/system/docker.service.d/override.conf
echo 'ExecStart=/usr/bin/dockerd \'>> /etc/systemd/system/docker.service.d/override.conf
echo '-H tcp://0.0.0.0:2376 \'>> /etc/systemd/system/docker.service.d/override.conf
echo '-H unix:///var/run/docker.sock \'>> /etc/systemd/system/docker.service.d/override.conf
echo '--storage-driver aufs \'>> /etc/systemd/system/docker.service.d/override.conf
echo '--tlsverify \'>> /etc/systemd/system/docker.service.d/override.conf
echo '--tlscacert=/home/vagrant/.certs/ca.pem \'>> /etc/systemd/system/docker.service.d/override.conf
echo '--tlscert=/home/vagrant/.certs/server-cert.pem \'>> /etc/systemd/system/docker.service.d/override.conf
echo '--tlskey=/home/vagrant/.certs/server-key.pem \'>> /etc/systemd/system/docker.service.d/override.conf
echo '--insecure-registry my-registry:5000'>> /etc/systemd/system/docker.service.d/override.conf
echo 'Environment='>> /etc/systemd/system/docker.service.d/override.conf
echo "ovverride.conf created in /etc/systemd/system/docker.service.d/"

sudo apt-get -y install expect
#systemctl daemon-reload 
expect -c 'spawn systemctl daemon-reload ; expect "Password:"; send "vagrant\r"; interact'
#systemctl restart docker 
expect -c 'spawn systemctl restart docker ; expect "Password:"; send "vagrant\r"; interact'