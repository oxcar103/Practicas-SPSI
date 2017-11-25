#! /bin/bash

# Directorios que contendrán los archivos
mkdir -p Resultados Claves/certs Claves/crl Claves/newcerts Claves/private

conf="-config my_openssl.cnf"       # Archivo de configuración personal
# Parámetros personales del certificado
param="/C=ES/ST=Andalusia/L=Granada/O=Oxcar103 Inc./OU=Oxcar103 Inc. Certificate Authority/CN=oxcar103/emailAddress=oxcar103@gmail.com"
CA_pl=/usr/lib/ssl/misc/CA.pl       # Dirección del script CA.pl
passwd="0123456789"

# Archivos recomendados para el CA
echo 1000 > ./Claves/serial
touch ./Claves/index.txt

# Generamos la CA raíz, que es un certificado auto-firmado
openssl req -new -passout pass:$passwd -x509 -days 103 $conf -subj "$param" #-keyout private/cakey.pem -out cacert.pem
# $CA_pl -newcert       # Equivalente usando el script CA.pl, salvo porque no le podemos pasar los parámetros por línea de comandos

