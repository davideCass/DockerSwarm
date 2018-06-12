#!/bin/bash
#break>/etc/systemd/system/docker.service.d/override.conf
#echo '[Service]' >> /etc/systemd/system/docker.service.d/override.conf
#echo 'ExecStart=' >> /etc/systemd/system/docker.service.d/override.conf
#echo 'ExecStart=/usr/bin/dockerd \'>> /etc/systemd/system/docker.service.d/override.conf
#echo '-H tcp://0.0.0.0:2376 \'>> /etc/systemd/system/docker.service.d/override.conf
#echo '-H unix:///var/run/docker.sock \'>> /etc/systemd/system/docker.service.d/override.conf
#echo '--storage-driver aufs \'>> /etc/systemd/system/docker.service.d/override.conf
#echo '--tlsverify \'>> /etc/systemd/system/docker.service.d/override.conf
#echo '--tlscacert=/home/vagrant/.certs/ca.pem \'>> /etc/systemd/system/docker.service.d/override.conf
#echo '--tlscert=/home/vagrant/.certs/server-cert.pem \'>> /etc/systemd/system/docker.service.d/override.conf
#echo '--tlskey=/home/vagrant/.certs/server-key.pem \'>> /etc/systemd/system/docker.service.d/override.conf
#echo '--insecure-registry my-registry:5000'>> /etc/systemd/system/docker.service.d/override.conf
#echo 'Environment='>> /etc/systemd/system/docker.service.d/override.conf
#echo "ovverride.conf created in /etc/systemd/system/docker.service.d/"

#systemctl daemon-reload 
sudo su 
sudo scp /home/asw/_shared/resources/override.conf /etc/systemd/system/docker.service.d/override.conf
#expect -c 'spawn ssh vagrant@swarm-1; expect "Are you sure you want to continue connecting (yes/no)?"; send "yes\r"; expect "password:"; send "vagrant\r"; interact'
#expect -c 'spawn systemctl daemon-reload ; expect "Password:"; send "vagrant\r"; interact'
#expect -c 'spawn systemctl restart docker ; expect "Password:"; send "vagrant\r"; interact'
sudo systemctl daemon-reload
sudo systemctl restart docker
echo "override.conf create in swarm-1"

# swarm-3
#expect -c 'spawn ssh vagrant@swarm-3 "sudo rm -f /etc/systemd/system/docker.service.d/override.conf"; expect "Are you sure you want to continue connecting (yes/no)?"; send "yes\r"; expect "password:"; send "vagrant\r"; interact'
sudo su
expect -c 'spawn ssh vagrant@swarm-3 "sudo scp /home/asw/_shared/resources/override.conf /etc/systemd/system/docker.service.d/override.conf"; expect "Are you sure you want to continue connecting (yes/no)?"; send "yes\r"; expect "password:"; send "vagrant\r"; interact'
expect -c 'spawn ssh vagrant@swarm-3 "sudo systemctl daemon-reload"; expect "password:"; send "vagrant\r"; interact'
expect -c 'spawn ssh vagrant@swarm-3 "sudo systemctl restart docker"; expect "password:"; send "vagrant\r"; interact'
#sudo scp /home/asw/_shared/resources/override.conf /etc/systemd/system/docker.service.d/override.conf
#expect -c 'spawn scp /home/asw/_shared/resources/override.conf vagrant@swarm-3:/etc/systemd/system/docker.service.d/override.conf; expect "password:"; send "vagrant\r"; interact'
#expect -c 'spawn  sudo systemctl daemon-reload; expect "password:"; send "vagrant\r"; interact'   # qui da errore 
#expect -c 'spawn  sudo systemctl restart docker; expect "password:"; send "vagrant\r"; interact'   
echo "override.conf create in swarm-3"

# swarm-2
expect -c 'spawn ssh vagrant@swarm-2; expect "Are you sure you want to continue connecting (yes/no)?"; send "yes\r"; expect "password:"; send "vagrant\r"; interact'
sudo su
sudo scp /home/asw/_shared/resources/override.conf /etc/systemd/system/docker.service.d/override.conf
#expect -c 'spawn scp /home/asw/_shared/resources/override.conf vagrant@swarm-3:/etc/systemd/system/docker.service.d/override.conf; expect "password:"; send "vagrant\r"; interact'
sudo systemctl daemon-reload
#expect -c 'spawn systemctl daemon-reload ; expect "Password:"; send "vagrant\r"; interact'
sudo systemctl restart docker
#expect -c 'spawn systemctl restart docker ; expect "Password:"; send "vagrant\r"; interact'
sleep 5
echo "override.conf create in swarm-2"
#systemctl restart docker 
#expect -c 'spawn systemctl restart docker ; expect "Password:"; send "vagrant\r"; interact'