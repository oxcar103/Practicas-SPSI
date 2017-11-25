#! /bin/bash

# Directorios que contendrán los archivos
mkdir -p Resultados Claves/certs Claves/crl Claves/newcerts Claves/private Claves/requests

conf="-config my_openssl.cnf"       # Archivo de configuración personal
param=$(cat param.txt)              # Parámetros personales del certificado
CA_pl=/usr/lib/ssl/misc/CA.pl       # Dirección del script CA.pl
passwd="0123456789"

# Archivos recomendados para el CA
echo 1000 > ./Claves/serial
touch ./Claves/index.txt

# Generamos la CA raíz, que es un certificado auto-firmado
openssl req -new -passout pass:$passwd -x509 -days 103 $conf -subj "$param" -keyout Claves/private/cakey.pem -out Claves/cacert.pem
# $CA_pl -newcert       # Equivalente usando el script CA.pl, salvo porque no le podemos pasar los parámetros por línea de comandos

# Generamos una nueva solicitud de certificado
openssl req -new -passout pass:$passwd $conf -subj "$param" -keyout Claves/private/newkey.pem -out Claves/requests/default_key.pem

