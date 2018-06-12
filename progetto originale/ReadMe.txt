TODO: 
modificare override.conf su ogni swarm-i con:
$ sudo nano /etc/systemd/system/docker.service.d/override.conf
cancellare quello che c'è dentro e copiare il contenuto di nuovo-override.conf, salvare ed eseguire:
$ systemctl daemon-reload
$ systemct restart docker
entrare in dev ed eseguire:
$ docker --tlsverify --tlscacert=/home/vagrant/.certs/ca.pem --tlscert=/home/vagrant/.certs/cert.pem --tlskey=/home/vagrant/.certs/key.pem   -H=10.11.1.72:2376 version