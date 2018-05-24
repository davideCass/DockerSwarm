#!/bin/bash

# da https://github.com/paulczar/omgwtfssl 
# https://github.com/paulczar/omgwtfssl/blob/master/generate-certs

# modificato per salvare tutti i certificati nella cartella ${CERTS_PATH} 
# il default è la cartella corrente $(pwd) (".") 

if [[ -z $SILENT ]]; then
echo "----------------------------"
echo "| OMGWTFSSL Cert Generator |"
echo "----------------------------"
echo
fi

export CERTS_PATH=${CERTS_PATH-$(pwd)}

export CA_KEY=${CERTS_PATH}/${CA_KEY-"ca-key.pem"}
export CA_CERT=${CERTS_PATH}/${CA_CERT-"ca.pem"}
export CA_SUBJECT=${CA_SUBJECT:-"test-ca"}
export CA_EXPIRE=${CA_EXPIRE:-"60"}

export SSL_CONFIG=${CERTS_PATH}/${SSL_CONFIG:-"openssl.cnf"}
export SSL_KEY=${CERTS_PATH}/${SSL_KEY:-"key.pem"}
export SSL_CSR=${CERTS_PATH}/${SSL_CSR:-"key.csr"}
export SSL_CERT=${CERTS_PATH}/${SSL_CERT:-"cert.pem"}
export SSL_SIZE=${SSL_SIZE:-"2048"}
export SSL_EXPIRE=${SSL_EXPIRE:-"60"}

export SSL_SUBJECT=${SSL_SUBJECT:-"example.com"}
export SSL_DNS=${SSL_DNS}
export SSL_IP=${SSL_IP}

export K8S_NAME=${K8S_NAME:-"omgwtfssl"}
export K8S_NAMESPACE=${K8S_NAMESPACE:-"default"}
export K8S_SAVE_CA_KEY=${K8S_SAVE_CA_KEY}
export K8S_SAVE_CA_CRT=${K8S_SAVE_CA_CRT}
export K8S_SHOW_SECRET_YAML=${K8S_SHOW_SECRET_YAML}

export OUTPUT=${OUTPUT:-"yaml"}

export SECRET_YAML=${CERTS_PATH}/secret.yaml

# se non esiste, crea la cartella per i certificati 

if [[ -d ${CERTS_PATH} ]]; then
    [[ -z $SILENT ]] && echo "====> Using existing certificate folder ${CERTS_PATH}"
else
    [[ -z $SILENT ]] && echo "====> Creating new certificate folder ${CERTS_PATH}"
    mkdir ${CERTS_PATH}
fi

# ora crea i certificati 

[[ -z $SILENT ]] && echo "--> Certificate Authority"

if [[ -e ${CA_KEY} ]]; then
    [[ -z $SILENT ]] && echo "====> Using existing CA Key ${CA_KEY}"
else
    [[ -z $SILENT ]] && echo "====> Generating new CA key ${CA_KEY}"
    openssl genrsa -out ${CA_KEY} ${SSL_SIZE} > /dev/null
fi

if [[ -e ${CA_CERT} ]]; then
    [[ -z $SILENT ]] && echo "====> Using existing CA Certificate ${CA_CERT}"
else
    [[ -z $SILENT ]] && echo "====> Generating new CA Certificate ${CA_CERT}"
    openssl req -x509 -new -nodes -key ${CA_KEY} -days ${CA_EXPIRE} -out ${CA_CERT} -subj "/CN=${CA_SUBJECT}" > /dev/null  || exit 1
fi

echo "====> Generating new config file ${SSL_CONFIG}"
cat > ${SSL_CONFIG} <<EOM
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
EOM

if [[ -n ${SSL_DNS} || -n ${SSL_IP} ]]; then
    cat >> ${SSL_CONFIG} <<EOM
subjectAltName = @alt_names
[alt_names]
EOM

    IFS=","
    dns=(${SSL_DNS})
    dns+=(${SSL_SUBJECT})
    for i in "${!dns[@]}"; do
      echo DNS.$((i+1)) = ${dns[$i]} >> ${SSL_CONFIG}
    done

    if [[ -n ${SSL_IP} ]]; then
        ip=(${SSL_IP})
        for i in "${!ip[@]}"; do
          echo IP.$((i+1)) = ${ip[$i]} >> ${SSL_CONFIG}
        done
    fi
fi

[[ -z $SILENT ]] && echo "====> Generating new SSL KEY ${SSL_KEY}"
openssl genrsa -out ${SSL_KEY} ${SSL_SIZE} > /dev/null || exit 1

[[ -z $SILENT ]] && echo "====> Generating new SSL CSR ${SSL_CSR}"
openssl req -new -key ${SSL_KEY} -out ${SSL_CSR} -subj "/CN=${SSL_SUBJECT}" -config ${SSL_CONFIG} > /dev/null || exit 1

[[ -z $SILENT ]] && echo "====> Generating new SSL CERT ${SSL_CERT}"
openssl x509 -req -in ${SSL_CSR} -CA ${CA_CERT} -CAkey ${CA_KEY} -CAcreateserial -out ${SSL_CERT} \
    -days ${SSL_EXPIRE} -extensions v3_req -extfile ${SSL_CONFIG} > /dev/null || exit 1

# create k8s secret file
cat << EOM > ${SECRET_YAML}
apiVersion: v1
kind: Secret
metadata:
  name: ${K8S_NAME}
  namespace: ${K8S_NAMESPACE}
type: kubernetes.io/tls
data:
EOM
if [[ -n $K8S_SAVE_CA_KEY ]]; then
    echo -n "  ca.key: " >> ${SECRET_YAML}
    cat $CA_KEY | base64 | tr '\n' ',' | sed 's/,//g' >> ${SECRET_YAML}
    echo >> ${SECRET_YAML}
fi
if [[ -n $K8S_SAVE_CA_CRT ]]; then
    echo -n "  ca.crt: " >> ${SECRET_YAML}
    cat $CA_CERT | base64 | tr '\n' ',' | sed 's/,//g' >> ${SECRET_YAML}
    echo >> ${SECRET_YAML}
fi
echo -n "  tls.key: " >> ${SECRET_YAML}
cat $SSL_KEY | base64 | tr '\n' ',' | sed 's/,//g' >> ${SECRET_YAML}
echo >> ${SECRET_YAML}
echo -n "  tls.crt: " >> ${SECRET_YAML}
cat $SSL_CERT | base64 | tr '\n' ',' | sed 's/,//g' >> ${SECRET_YAML}
echo >> ${SECRET_YAML}

if [[ -z $SILENT ]]; then
echo "====> Complete"
echo "keys can be found in volume mapped to $(pwd)"
echo

if [[ ${OUTPUT} == "k8s" ]]; then
  echo "====> Output results as base64 k8s secrets"
  echo "---"
  cat ${SECRET_YAML}

else
  echo "====> Output results as YAML"
  echo "---"
  echo "ca_key: |"
  cat $CA_KEY | sed 's/^/  /'
  echo
  echo "ca_crt: |"
  cat $CA_CERT | sed 's/^/  /'
  echo
  echo "ssl_key: |"
  cat $SSL_KEY | sed 's/^/  /'
  echo
  echo "ssl_csr: |"
  cat $SSL_CSR | sed 's/^/  /'
  echo
  echo "ssl_crt: |"
  cat $SSL_CERT | sed 's/^/  /'
  echo
fi
fi