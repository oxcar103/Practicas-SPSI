#! /bin/bash

# Directorios que contendrán los archivos
mkdir -p Resultados
mkdir -p Claves

# Archivo de 0's
dd if=/dev/zero of=./Resultados/input.bin bs=128 count=1 2> /dev/null
xxd ./Resultados/input.bin > ./Resultados/input.txt

size=103
name=${1:-My}           # Primer parámetro, por defecto "My"
surname=${2:-Other}     # Primer parámetro, por defecto "Other"
passwd="0123456789"
curve="prime192v1"
mode="-aes-128-cfb8"
key="./Claves/key.bin"

# Generación de clave DSA
openssl dsaparam -out ./Claves/"sharedDSA.pem" $size

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

# Generación de valores Hash
openssl dgst -sha384 -c -out ./Resultados/$name"DSApub.sha384" ./Claves/$name"DSApub.pem"
openssl dgst -ripemd160 -c -out ./Resultados/$surname"DSApub.ripemd160" ./Claves/$surname"DSApub.pem"
openssl dgst -hmac "12345" -c -out ./Resultados/"sharedDSA.hmac" ./Claves/"sharedDSA.pem"

# Simulación del protocolo Estación a Estación
# Generación de clave por curva elíptica
openssl ecparam -name $curve -out ./Claves/"stdECparam.pem"

for i in $name $surname
    do
        openssl ecparam -in ./Claves/"stdECparam.pem" -genkey -out ./Claves/$i"ECkey.pem"
        openssl ec -des3 -passout pass:$passwd -in ./Claves/$i"ECkey.pem" -out ./Claves/$i"ECpriv.pem"
        openssl ec -pubout -in ./Claves/$i"ECkey.pem" -out ./Claves/$i"ECpub.pem"
    done

msg="message.txt"
pubA="pubA.pem"
pubB="pubB.pem"
tmp="tmp.txt"
# Alice
cat ./Claves/$name"ECpub.pem" > $msg

# Bob
cat $msg > $pubA
openssl pkeyutl -derive -passin pass:$passwd -inkey ./Claves/$surname"ECpriv.pem" -peerkey $pubA -out $key
openssl dgst -sha256 -passin pass:$passwd -sign ./Claves/$surname"DSApriv.pem" -out ./Resultados/"sgnB.bin" <(cat $pubA ./Claves/$surname"ECpub.pem")
openssl enc $mode -pass file:$key -in ./Resultados/"sgnB.bin" -out ./Resultados/"sgnB_enc.bin"
cat ./Claves/$surname"ECpub.pem" ./Resultados/"sgnB_enc.bin" > $msg

# Alice
cat $msg | head -n -1 > $pubB
cat $msg | tail -n 1 > $tmp
openssl pkeyutl -derive -passin pass:$passwd -inkey ./Claves/$name"ECpriv.pem" -peerkey $pubB -out $key
openssl enc -d $mode -pass file:$key -in $tmp -out ./Resultados/"sgnB_dec.bin"
openssl dgst -sha256 -verify ./Claves/$surname"DSApub.pem" -signature ./Resultados/"sgnB_dec.bin" <(cat ./Claves/$name"ECpub.pem" $pubB)
openssl dgst -sha256 -passin pass:$passwd -sign ./Claves/$name"DSApriv.pem" -out ./Resultados/"sgnA.bin" <(cat $pubB ./Claves/$name"ECpub.pem")
openssl enc $mode -pass file:$key -in ./Resultados/"sgnA.bin" -out ./Resultados/"sgnA_enc.bin"
cat ./Resultados/"sgnA_enc.bin" > $msg

# Bob
cat $msg > $tmp
openssl enc -d $mode -pass file:$key -in $tmp -out ./Resultados/"sgnA_dec.bin"
openssl dgst -sha256 -verify ./Claves/$name"DSApub.pem" -signature ./Resultados/"sgnA_dec.bin" <(cat ./Claves/$surname"ECpub.pem" $pubA)

# Borra archivos temporales de los mensajes entre Alice y Bob
rm $msg $pubA $pubB $tmp

