#!/bin/bash

# https://docs.docker.com/registry/deploying/

echo 'Starting private secure registry as a service -> my-registry:433' 

# nell'ambiente docker-swarm, il registry puo' essere acceduto su my-registry:433 
# my-registry e' un alias per swarm-1
# inoltre, anche my-swarm e' un alias per swarm-1 

# si assicura che la cartella /home/asw/data/my-registry sia stata creata 

mkdir -p /home/asw/data/my-registry

export DOCKER_HOST=tcp://swarm-1:2376

docker --tlsverify --tlscacert=/home/vagrant/.certs/ca.pem --tlscert=/home/vagrant/.certs/cert.pem --tlskey=/home/vagrant/.certs/key.pem -H=swarm-1:2376 secret create domain.crt /home/vagrant/.certs/reg-cert.pem

docker --tlsverify --tlscacert=/home/vagrant/.certs/ca.pem --tlscert=/home/vagrant/.certs/cert.pem --tlskey=/home/vagrant/.certs/key.pem -H=swarm-1:2376 secret create domain.key /home/vagrant/.certs/reg-key.pem

docker --tlsverify --tlscacert=/home/vagrant/.certs/ca.pem --tlscert=/home/vagrant/.certs/cert.pem --tlskey=/home/vagrant/.certs/key.pem -H=swarm-1:2376 node update --label-add registry=true swarm-1

docker --tlsverify --tlscacert=/home/vagrant/.certs/ca.pem --tlscert=/home/vagrant/.certs/cert.pem --tlskey=/home/vagrant/.certs/key.pem -H=swarm-1:2376 service create \
  --name my-registry \
  --secret domain.crt \
  --secret domain.key \
  --constraint 'node.labels.registry==true' \
  --mount type=bind,src=/home/asw/data/my-registry,dst=/var/lib/registry \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:433 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/run/secrets/domain.crt \
  -e REGISTRY_HTTP_TLS_KEY=/run/secrets/domain.key \
  --publish published=433,target=433 \
  --replicas 1 \
  registry:2