#! /bin/bash

# Archivo de 0's
dd if=/dev/zero of=input.bin bs=128 count=1 2> /dev/null

key_size="768"
name=${1:-My}       # Primer parámetro, por defecto "My"
passwd="0123456789"
curve="prime192v1"


# Generación de clave RSA
openssl genrsa -out $name"RSAkey.pem" $key_size
openssl rsa -aes128 -passout pass:$passwd -in $name"RSAkey.pem" -out $name"RSApriv.pem"
openssl rsa -pubout -in $name"RSAkey.pem" -out $name"RSApub.pem"

# Generación de clave por curva elíptica
openssl ecparam -name $curve -out "stdECparam.pem"
openssl ecparam -in "stdECparam.pem" -genkey -out $name"ECkey.pem" 
openssl ec -des3 -passout pass:$passwd -in $name"ECkey.pem" -out $name"ECpriv.pem"
openssl ec -pubout -in $name"ECkey.pem" -out $name"ECpub.pem"
