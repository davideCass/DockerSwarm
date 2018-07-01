#!/bin/bash
#informazioni prese da https://github.com/docker/docker.github.io/blob/master/swarm/configure-tls.md
#to do on swarm-1 as a CA

#genera certificato e chiave per la CA cioè i file ca.pem e ca-priv-key.pem
echo "genera certificati e chiavi dei nodi"
sudo su
mkdir certs
cd certs
openssl genrsa -out ca-priv-key.pem 2048
printf '.\n.\n.\n.\n.\nexample.com\n.\n' | openssl req -config /usr/lib/ssl/openssl.cnf -new -key ca-priv-key.pem -x509 -days 1825 -out ca.pem
#come common name per prova ho usato example.com, gli altri campi sono stati lasciati vuoti

#genera le chiavi per i singoli nodi, va ripetuto per tutti i nodi
#swarm-1
openssl genrsa -out swarm-1-priv-key.pem 2048
openssl req -subj "/CN=swarm-1" -new -key swarm-1-priv-key.pem -out swarm-1.csr
openssl x509 -req -days 1825 -in swarm-1.csr -CA ca.pem -CAkey ca-priv-key.pem -CAcreateserial -out swarm-1-cert.pem -extensions v3_req -extfile /usr/lib/ssl/openssl.cnf
openssl rsa -in swarm-1-priv-key.pem -out swarm-1-priv-key.pem

#swarm-2
openssl genrsa -out swarm-2-priv-key.pem 2048
openssl req -subj "/CN=swarm-2" -new -key swarm-2-priv-key.pem -out swarm-2.csr
openssl x509 -req -days 1825 -in swarm-2.csr -CA ca.pem -CAkey ca-priv-key.pem -CAcreateserial -out swarm-2-cert.pem -extensions v3_req -extfile /usr/lib/ssl/openssl.cnf
openssl rsa -in swarm-2-priv-key.pem -out swarm-2-priv-key.pem

#swarm-3
openssl genrsa -out swarm-3-priv-key.pem 2048
openssl req -subj "/CN=swarm-3" -new -key swarm-3-priv-key.pem -out swarm-3.csr
openssl x509 -req -days 1825 -in swarm-3.csr -CA ca.pem -CAkey ca-priv-key.pem -CAcreateserial -out swarm-3-cert.pem -extensions v3_req -extfile /usr/lib/ssl/openssl.cnf
openssl rsa -in swarm-3-priv-key.pem -out swarm-3-priv-key.pem

#dev
openssl genrsa -out dev-priv-key.pem 2048
openssl req -subj "/CN=dev" -new -key dev-priv-key.pem -out dev.csr
openssl x509 -req -days 1825 -in dev.csr -CA ca.pem -CAkey ca-priv-key.pem -CAcreateserial -out dev-cert.pem -extensions v3_req -extfile /usr/lib/ssl/openssl.cnf
openssl rsa -in dev-priv-key.pem -out dev-priv-key.pem

#genera le chiavi per il registry
#registry
openssl genrsa -out reg-key.pem 2048
openssl req -subj "/CN=my-registry" -new -key reg-key.pem -out reg.csr
openssl x509 -req -days 1825 -in reg.csr -CA ca.pem -CAkey ca-priv-key.pem -CAcreateserial -out reg-cert.pem -extensions v3_req -extfile /usr/lib/ssl/openssl.cnf
openssl rsa -in reg-key.pem -out reg-key.pem

echo "certificati e chiavi create"

#copia i certificati nella cartella /home/asw/_shared/resources/certs
cp -r /home/vagrant/certs /home/asw/_shared/resources