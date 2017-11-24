#! /bin/bash

# Directorios que contendrán los archivos
mkdir -p Resultados Claves/certs Claves/crl Claves/newcerts Claves/private

conf="-config my_openssl.cnf"

# Archivos recomendados para el CA
echo 1000 > ./Claves/serial
touch ./Claves/index.txt

# Generamos la CA raíz, que es un certificado auto-firmado
openssl req -new -x509 -days 103 -config my_openssl.cnf #-keyout private/cakey.pem -out cacert.pem

