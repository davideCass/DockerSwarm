#!/bin/bash

#da lanciare su swarm-1

sudo su
mkdir .certs

#copia delle chiavi (chiave e certificato di swarm-1 e il certificato della CA)
scp /home/asw/_shared/resources/certs/ca.pem /home/vagrant/.certs/ca.pem
scp /home/asw/_shared/resources/certs/swarm-1-cert.pem /home/vagrant/.certs/cert.pem
scp /home/asw/_shared/resources/certs/swarm-1-priv-key.pem /home/vagrant/.certs/key.pem


# copia le chiavi per il registry, non c'è bisogno di copiare nuovamente ca.pem
# essendo questa parte logicamente separata si potrebbe metterla in un altro script, è stata lasciata qui per comodità
scp /home/asw/_shared/resources/certs/reg-cert.pem /home/vagrant/.certs/reg-cert.pem
scp /home/asw/_shared/resources/certs/reg-key.pem /home/vagrant/.certs/reg-key.pem
echo "chiavi installate su swarm-1"


# modifica di daemon.json e override.conf e riavvio del demone

rm -f /etc/docker/daemon.json
echo '{' >> /etc/docker/daemon.json
echo '}' >> /etc/docker/daemon.json
echo "daemon.json created in /etc/docker/"

rm -f /etc/systemd/system/docker.service.d/override.conf
echo '[Service]' >> /etc/systemd/system/docker.service.d/override.conf
echo 'ExecStart=' >> /etc/systemd/system/docker.service.d/override.conf
echo 'ExecStart=/usr/bin/dockerd \'>> /etc/systemd/system/docker.service.d/override.conf
echo '-H tcp://0.0.0.0:2376 \' >> /etc/systemd/system/docker.service.d/override.conf
echo '-H unix:///var/run/docker.sock \' >> /etc/systemd/system/docker.service.d/override.conf
echo '--storage-driver aufs \' >> /etc/systemd/system/docker.service.d/override.conf
echo '--tlsverify \' >> /etc/systemd/system/docker.service.d/override.conf
echo '--tlscacert=/home/vagrant/.certs/ca.pem \' >> /etc/systemd/system/docker.service.d/override.conf
echo '--tlscert=/home/vagrant/.certs/cert.pem \' >> /etc/systemd/system/docker.service.d/override.conf
echo '--tlskey=/home/vagrant/.certs/key.pem' >> /etc/systemd/system/docker.service.d/override.conf
echo 'Environment=' >> /etc/systemd/system/docker.service.d/override.conf
echo "override.conf created in /etc/systemd/system/docker.service.d/"


systemctl daemon-reload
echo "daemon-reload eseguito"
systemctl restart docker
echo "docker daemon riavviato su swarm-1"


# esporta il due variabili d'ambiente che indicano al demone docker di connettersi usando autenticazione a due vie e il percorso delle chiavi

echo "export DOCKER_TLS_VERIFY=1" >> ./.bash_profile
echo "export DOCKER_CERT_PATH=/home/vagrant/.certs/" >> ./.bash_profile
source ./.bash_profile
echo "variabili d'ambiente esportate"