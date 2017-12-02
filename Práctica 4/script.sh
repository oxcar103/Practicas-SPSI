#! /bin/bash

# Directorios que contendrán los archivos
mkdir -p Resultados Solicitudes Claves/certs Claves/crl Claves/newcerts Claves/private

conf="-config my_openssl.cnf"       # Archivo de configuración personal
param=$(cat param.txt)              # Parámetros personales del certificado
CA_pl=/usr/lib/ssl/misc/CA.pl       # Dirección del script CA.pl
passwd="0123456789"
size=1024

# Archivos necesarios para el CA
echo "1000" > Claves/serial
touch ./Claves/index.txt

# Generamos la CA raíz, que es un certificado auto-firmado
openssl req -new -passout pass:$passwd -x509 -days 103 $conf -subj "$param" -keyout Claves/private/cakey.pem -out Claves/cacert.pem
# Equivalente usando el script CA.pl, salvo porque no le podemos pasar los parámetros por línea de comandos
# $CA_pl -newca         # Para crear la jerarquía de directorios
# $CA_pl -newcert       # Para crear un certificado auto-firmado

# Generamos una nueva solicitud de certificado
openssl req -new -passout pass:$passwd $conf -subj "$param" -keyout Claves/private/default_key.pem -out Solicitudes/default_key.pem

# Certificamos la nueva solicitud
openssl ca -batch -noemailDN -passin pass:$passwd $conf -in Solicitudes/default_key.pem -out Claves/newcerts/default_key.pem 2> Resultados/default_key.txt
# $CA_pl -signreq       # Equivalente usando el script CA.pl

# Generamos una clave DSA igual que en la práctica 3
openssl dsaparam -out ./Claves/sharedDSA.pem $size
openssl gendsa -out ./Claves/DSAkey.pem ./Claves/sharedDSA.pem
openssl dsa -aes128 -passout pass:$passwd -in ./Claves/DSAkey.pem -out ./Claves/private/DSApriv.pem
openssl dsa -pubout -in ./Claves/DSAkey.pem -out ./Claves/DSApub.pem

# Generamos una nueva solicitud de certificado de una clave existente
openssl req -new -passin pass:$passwd $conf -subj "$param" -key Claves/private/DSApriv.pem -out Solicitudes/prev_key.pem

# Certificamos la nueva solicitud
openssl ca -batch -noemailDN -passin pass:$passwd $conf -in Solicitudes/prev_key.pem -out Claves/newcerts/prev_key.pem 2> Resultados/prev_key.txt
# $CA_pl -signreq       # Equivalente usando el script CA.pl

# Creando archivos para ver los valores
for i in $(ls Solicitudes/*.pem | cut -f 1 -d "." | cut -f 2 -d "/")
    do
        openssl req -in Solicitudes/$i.pem -out Resultados/r_$i.txt -text -noout        # Solicitudes de certificados
    done

openssl x509 -in Claves/cacert.pem > Resultados/cacert.txt -text -noout                 # CA raíz

for i in $(ls Claves/newcerts/*.pem | cut -f 1 -d "." | cut -f 3 -d "/")
    do
        openssl x509 -in Claves/newcerts/$i.pem > Resultados/c_$i.txt -text -noout      # Certificados aprobados
    done
