#!/bin/bash


# da eseguire sul nodo swarm-1 
# richiede che su ciascun nodo dello swarm sia abilitato l'accesso remoto 


echo "Creating swarm on swarm-1" 


docker swarm init --advertise-addr 10.11.1.71

SWARM_TOKEN=$(docker swarm join-token -q worker)
SWARM_MASTER=$(docker info --format "{{.Swarm.NodeAddr}}")


echo "Swarm master: ${SWARM_MASTER}"
echo "Swarm token: ${SWARM_TOKEN}"


echo "Adding swarm-2 and swarm-3" 


docker -H=swarm-2:2376 --tlsverify --tlscacert=./.certs/ca.pem --tlscert=./.certs/cert.pem --tlskey=./.certs/key.pem swarm join --token ${SWARM_TOKEN} ${SWARM_MASTER}:2377
docker -H=swarm-3:2376 --tlsverify --tlscacert=./.certs/ca.pem --tlscert=./.certs/cert.pem --tlskey=./.certs/key.pem swarm join --token ${SWARM_TOKEN} ${SWARM_MASTER}:2377
