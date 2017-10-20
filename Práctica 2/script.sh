#! /bin/bash

# Archivo de 0's
dd if=/dev/zero of=input.bin bs=128 count=1 2> /dev/null

key_size="768"
name=${1:-My}       # Primer parámetro, por defecto "My"
passwd="0123456789"



# Generación de clave RSA
openssl genrsa -out $name"RSAkey.pem" $key_size
openssl rsa -aes128 -passout pass:$passwd -in $name"RSAkey.pem" -out $name"RSApriv.pem"
openssl rsa -pubout -in $name"RSAkey.pem" -out $name"RSApub.pem"
