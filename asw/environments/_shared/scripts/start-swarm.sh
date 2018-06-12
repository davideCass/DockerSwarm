#!/bin/bash

# da eseguire sul nodo swarm-1 
# richiede che su ciascun nodo dello swarm sia abilitato l'accesso remoto 

echo "Creating swarm on swarm-1" 

docker swarm init --advertise-addr 10.11.1.71
#init sembra entrare in loop
#sudo export TOKEN=$(docker run --rm swarm create)
#docker run --rm swarm create

#devo fare join di swarm-1?
#come passo il token agli altri? eseguo join remoto da swarm-1?
#su altri nodi 
#sudo docker run -d swarm join --addr=node1:2376 token://$TOKEN

SWARM_TOKEN=$(docker swarm join-token -q worker)
SWARM_MASTER=$(docker info --format "{{.Swarm.NodeAddr}}")

echo "Swarm master: ${SWARM_MASTER}"
echo "Swarm token: ${SWARM_TOKEN}"

echo "Adding swarm-2 and swarm-3" 

#docker -H=swarm-2:2376 --tlsverify --tlscacert=./.certs/ca.pem --tlscert=./.certs/cert.pem --tlskey=./.cert
#s/key.pem swarm join --token SWMTKN-1-0m4lyvwp7qq596ipm4qz6io937k585gb3egsap3j11h080an48-bcpgp1xldh3b6hd3io63nqc71 10.11.1.71:
#2377

docker -H=swarm-2:2376 --tlsverify --tlscacert=./.certs/ca.pem --tlscert=./.certs/cert.pem --tlskey=./.certs/key.pem swarm join --token ${SWARM_TOKEN} ${SWARM_MASTER}:2377
#docker --host 10.11.1.72:2376 swarm join --token ${SWARM_TOKEN} ${SWARM_MASTER}:2377
docker -H=swarm-3:2376 --tlsverify --tlscacert=./.certs/ca.pem --tlscert=./.certs/cert.pem --tlskey=./.certs/key.pem swarm join --token ${SWARM_TOKEN} ${SWARM_MASTER}:2377
#docker --host 10.11.1.73:2376 swarm join --token ${SWARM_TOKEN} ${SWARM_MASTER}:2377
