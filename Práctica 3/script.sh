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

# Generación de clave DSA
openssl dsaparam -out ./Claves/"sharedDSA.pem"

for i in $name $surname
    do
        openssl gendsa -out ./Claves/$i"DSAkey.pem" ./Claves/"sharedDSA.pem"
        openssl dsa -aes128 -passout pass:$passwd -in ./Claves/$i"DSAkey.pem" -out ./Claves/$i"DSApriv.pem"
        openssl dsa -pubout -in ./Claves/$i"DSAkey.pem" -out ./Claves/$i"DSApub.pem"
    done

# Creando archivos para mostrar los valores
openssl dsaparam -text -noout -in ./Claves/"sharedDSA.pem" -out ./Resultados/"sharedDSA.txt"

for i in $name $surname
    do
        openssl dsa -text -noout -in ./Claves/$i"DSAkey.pem" -out ./Resultados/$i"DSAkey.txt"
        openssl dsa -text -noout -passin pass:$passwd -in ./Claves/$i"DSApriv.pem" -out ./Resultados/$i"DSApriv.txt"
        openssl dsa -text -noout -pubin -in ./Claves/$i"DSApub.pem" -out ./Resultados/$i"DSApub.txt"
    done

# Generación de clave por curva elíptica
openssl ecparam -name $curve -out ./Claves/"stdECparam.pem"

for i in $name $surname
    do
        openssl ecparam -in ./Claves/"stdECparam.pem" -genkey -out ./Claves/$i"ECkey.pem"
        openssl ec -des3 -passout pass:$passwd -in ./Claves/$i"ECkey.pem" -out ./Claves/$i"ECpriv.pem"
        openssl ec -pubout -in ./Claves/$i"ECkey.pem" -out ./Claves/$i"ECpub.pem"
    done
