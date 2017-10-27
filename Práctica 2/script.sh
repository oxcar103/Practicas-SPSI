#! /bin/bash

# Directorios que contendrán los archivos
mkdir -p Resultados
mkdir -p Claves

# Archivo de 0's
dd if=/dev/zero of=./Resultados/input.bin bs=128 count=1 2> /dev/null

key_size="768"
name=${1:-My}       # Primer parámetro, por defecto "My"
passwd="0123456789"
curve="prime192v1"
fkey="sessionkey"
mode="-aes-256-cbc"

# Generación de clave RSA
openssl genrsa -out ./Claves/$name"RSAkey.pem" $key_size
openssl rsa -aes128 -passout pass:$passwd -in ./Claves/$name"RSAkey.pem" -out ./Claves/$name"RSApriv.pem"
openssl rsa -pubout -in ./Claves/$name"RSAkey.pem" -out ./Claves/$name"RSApub.pem"

# Cifrar con clave pública
# openssl rsautl -encrypt -passin pass:$passwd -pubin -inkey $name"RSApub.pem" -in "input.bin" -out "input_RSA.bin"

# Cifrado híbrido
# Cifrando...
openssl rand 32 -hex -out ./Resultados/$fkey         # 32 caracteres hexadecimales = 256 de tamaño de clave
echo $mode >> ./Resultados/$fkey
openssl rsautl -encrypt -pubin -inkey ./Claves/$name"RSApub.pem" -in ./Resultados/$fkey -out ./Resultados/$fkey".enc"
openssl enc $mode -pass file:./Resultados/$fkey -in ./Resultados/"input.bin" -out ./Resultados/"output.bin"

# Descifrando...
openssl rsautl -decrypt -passin pass:$passwd -inkey ./Claves/$name"RSApriv.pem" -in ./Resultados/$fkey".enc" -out ./Resultados/$fkey".dec"
dec_mode=`cat ./Resultados/$fkey".dec" | tail -n 1`
openssl enc -d $dec_mode -pass file:./Resultados/$fkey".dec" -in ./Resultados/"output.bin" -out ./Resultados/"output_dec.bin"

# Generación de clave por curva elíptica
openssl ecparam -name $curve -out ./Claves/"stdECparam.pem"
openssl ecparam -in ./Claves/"stdECparam.pem" -genkey -out ./Claves/$name"ECkey.pem"
openssl ec -des3 -passout pass:$passwd -in ./Claves/$name"ECkey.pem" -out ./Claves/$name"ECpriv.pem"
openssl ec -pubout -in ./Claves/$name"ECkey.pem" -out ./Claves/$name"ECpub.pem"
