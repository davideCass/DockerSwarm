#!/bin/bash
#da lanciare su dev

sudo su
#echo "===================installazione di expect================="
#apt-get -y install expect
#echo "===================installazione di expect completata======================="

mkdir .certs

#dev
#copia delle chiavi
#le chiavi non vengono copiate, a quanto pare anche con sudo su da permission denied
#potrebbe convenire copiare le chiavi da dev in resources e da lì ogni macchina si prende le sue
#expect -c 'spawn  ssh vagrant@dev "mkdir -p /home/vagrant/.certs"; expect "frase(yes/no):"; send "yes"; expect "password:"; send "vagrant\r"; interact'
#scp ./ca.pem vagrant@dev:/home/vagrant/.certs/ca.pem
scp /home/asw/_shared/resources/certs/ca.pem /home/vagrant/.certs/ca.pem
#scp ./dev-cert.pem vagrant@dev:/home/vagrant/.certs/cert.pem
scp /home/asw/_shared/resources/certs/dev-cert.pem /home/vagrant/.certs/cert.pem
#scp ./dev-priv-key.pem vagrant@dev:/home/vagrant/.certs/key.pem
scp /home/asw/_shared/resources/certs/dev-priv-key.pem /home/vagrant/.certs/key.pem
echo "chiavi installate su dev"

# modifica di daemon.json e override.conf e riavvio del demone
#/home/asw/_shared/scripts/create-daemonjson.sh
# va eliminato il file se presente ma il comando break non funziona
#break>/etc/docker/daemon.json
rm -f /etc/docker/daemon.json
echo '{' >> /etc/docker/daemon.json
echo '}' >> /etc/docker/daemon.json
echo "daemon.json created in /etc/docker/"

#/home/asw/_shared/scripts/create-overrideconf.sh
# va eliminato il file se presente ma il comando break non funziona
#break>/etc/systemd/system/docker.service.d/override.conf
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
echo '--tlskey=/home/vagrant/.certs/key.pem \' >> /etc/systemd/system/docker.service.d/override.conf
echo '--insecure-registry my-registry:5000' >> /etc/systemd/system/docker.service.d/override.conf
echo 'Environment=' >> /etc/systemd/system/docker.service.d/override.conf
echo "override.conf created in /etc/systemd/system/docker.service.d/"


## errore, bisogna eliminare i file vecchi

systemctl daemon-reload
echo "daemon-reload eseguito"
systemctl restart docker
echo "docker daemon riavviato su dev"