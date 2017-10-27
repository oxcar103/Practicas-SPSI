#! /bin/bash

# Archivo de 0's
dd if=/dev/zero of=input.bin bs=128 count=1 2> /dev/null

key_size="768"
name=${1:-My}       # Primer parámetro, por defecto "My"
passwd="0123456789"
curve="prime192v1"
fkey="sessionkey"
mode="-aes-256-cbc"

# Generación de clave RSA
openssl genrsa -out $name"RSAkey.pem" $key_size
openssl rsa -aes128 -passout pass:$passwd -in $name"RSAkey.pem" -out $name"RSApriv.pem"
openssl rsa -pubout -in $name"RSAkey.pem" -out $name"RSApub.pem"

# Cifrar con clave pública
# openssl rsautl -encrypt -passin pass:$passwd -pubin -inkey $name"RSApub.pem" -in "input.bin" -out "input_RSA.bin"

# Cifrado híbrido
# Cifrando...
openssl rand 32 -hex -out $fkey         # 32 caracteres hexadecimales = 256 de tamaño de clave
echo $mode >> $fkey
openssl rsautl -encrypt -pubin -inkey $name"RSApub.pem" -in $fkey -out $fkey".enc"
openssl enc $mode -pass file:$fkey -in "input.bin" -out "output.bin"

# Generación de clave por curva elíptica
openssl ecparam -name $curve -out "stdECparam.pem"
openssl ecparam -in "stdECparam.pem" -genkey -out $name"ECkey.pem" 
openssl ec -des3 -passout pass:$passwd -in $name"ECkey.pem" -out $name"ECpriv.pem"
openssl ec -pubout -in $name"ECkey.pem" -out $name"ECpub.pem"
