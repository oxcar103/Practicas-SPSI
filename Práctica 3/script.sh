#! /bin/bash

# Directorios que contendrán los archivos
mkdir -p Resultados
mkdir -p Claves

# Archivo de 0's
dd if=/dev/zero of=./Resultados/input.bin bs=128 count=1 2> /dev/null
xxd ./Resultados/input.bin > ./Resultados/input.txt

name=${1:-My}           # Primer parámetro, por defecto "My"
surname=${2:-Other}     # Primer parámetro, por defecto "Other"
passwd="0123456789"
curve="prime192v1"
mode="-aes-128-cfb8"

# Generación de clave por curva elíptica
openssl ecparam -name $curve -out ./Claves/"stdECparam.pem"

for i in $name $surname
    do
        openssl ecparam -in ./Claves/"stdECparam.pem" -genkey -out ./Claves/$i"ECkey.pem"
        openssl ec -des3 -passout pass:$passwd -in ./Claves/$i"ECkey.pem" -out ./Claves/$i"ECpriv.pem"
        openssl ec -pubout -in ./Claves/$i"ECkey.pem" -out ./Claves/$i"ECpub.pem"
    done
