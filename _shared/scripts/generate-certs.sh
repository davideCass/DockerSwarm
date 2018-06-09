#!/bin/bash
# genera chiave ca-key.pem

export CERTS_PATH=${CERTS_PATH-/home/asw/_shared/resources}		#${CERTS_PATH-$(pwd)}

export CA_KEY=${CERTS_PATH}/${CA_KEY-"ca-key.pem"}
export CA_CERT=${CERTS_PATH}/${CA_CERT-"ca.pem"}
export CA_SUBJECT=${CA_SUBJECT:-"test-ca"}
export CA_EXPIRE=${CA_EXPIRE:-"365"}

export SSL_CONFIG=${CERTS_PATH}/${SSL_CONFIG:-"openssl.cnf"}
export SSL_KEY=${CERTS_PATH}/${SSL_KEY:-"server-key.pem"}
export SSL_CSR=${CERTS_PATH}/${SSL_CSR:-"server-key.csr"}
export SSL_CERT=${CERTS_PATH}/${SSL_CERT:-"server-cert.pem"}
export SSL_CLIENT_KEY=${CERTS_PATH}/${SSL_CLIENT_KEY:-"client-key.pem"}
export SSL_CLIENT_CSR=${CERTS_PATH}/${SSL_CLIENT_CSR:-"client-key.csr"}
export SSL_CLIENT_CERT=${CERTS_PATH}/${SSL_CLIENT_CERT:-"client-cert.pem"}

export SSL_SUBJECT=${SSL_SUBJECT:-"example.com"}
export SSL_CLIENT_SUBJECT=${SSL_CLIENT_SUBJECT:-"dev"}

chmod u+w ${CA_KEY} ${CA_CERT} ${SSL_KEY} ${SSL_CSR} ${SSL_CONFIG} ${SSL_CERT} ${SSL_CLIENT_KEY} ${SSL_CLIENT_CSR} ${SSL_CLIENT_CERT}
break>${SSL_CONFIG}

openssl genrsa -out ${CA_KEY} 2048
# genera ca.pem
printf '.\n.\n.\n.\n.\nexample.com\n.\n' | openssl req -new -x509 -days 365 -key ${CA_KEY} -out ${CA_CERT}

# genera server-key.pem
openssl genrsa -out ${SSL_KEY} 2048
openssl req -subj "/CN=example.com" -new -key ${SSL_KEY} -out ${SSL_CSR}

sudo echo subjectAltName = DNS:example.com,IP:10.11.1.71, IP:10.11.1.72, IP:10.11.1.73,IP:127.0.0.1 >> ${SSL_CONFIG}
sudo echo extendedKeyUsage = serverAuth >> ${SSL_CONFIG}

# genera server-cert.pem
openssl x509 -req -days 365 -in ${SSL_CSR} -CA ${CA_CERT} -CAkey ${CA_KEY} -CAcreateserial -out ${SSL_CERT} -extfile ${SSL_CONFIG}

# genera chiave client key.pem
openssl genrsa -out ${SSL_CLIENT_KEY} 2048
openssl req -subj '/CN=client' -new -key ${SSL_CLIENT_KEY} -out ${SSL_CLIENT_CSR}
echo extendedKeyUsage = clientAuth >> ${SSL_CONFIG}

# genera client cert cert.pem
openssl x509 -req -days 365 -in ${SSL_CLIENT_CSR} -CA ${CA_CERT} -CAkey ${CA_KEY} -CAcreateserial -out ${SSL_CLIENT_CERT} -extfile ${SSL_CONFIG}

#rm -v client.csr server.csr
#chmod -v 0400 ${CA_KEY} ${SSL_CLIENT_KEY} ${SSL_KEY}
#chmod -v 0444 ${CA_CERT} ${SSL_CERT} ${SSL_CLIENT_CERT}