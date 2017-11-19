#! /bin/bash

# Directorios que contendrán los archivos
mkdir -p Resultados Claves

size=1024
name=${1:-My}           # Primer parámetro, por defecto "My"
surname=${2:-Other}     # Segundo parámetro, por defecto "Other"
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

# Generación de archivos temporales
msg="message.txt"
pubA="publicA.pem"
pubB="publicB.pem"
sgn="signature.txt"

# Alice
    # Pasa su clave: c = g^a
    cat ./Claves/$name"ECpub.pem" > $msg
# Bob
    # Lee la clave de Alice: c
    cat $msg > $pubA
    # Calcula la clave compartida: k = c^b = g^(ab)
    openssl pkeyutl -derive -passin pass:$passwd -inkey ./Claves/$surname"ECpriv.pem" -peerkey $pubA -out $key
    # Firma (c || d): s = sgn_B (c || d)
    openssl dgst -sha256 -passin pass:$passwd -sign ./Claves/$surname"DSApriv.pem" -out ./Resultados/"sgnB.bin" <(cat $pubA ./Claves/$surname"ECpub.pem")
    # Cifra la firma: e_k(s)
    openssl enc $mode -pass file:$key -in ./Resultados/"sgnB.bin" -out ./Resultados/"sgnB_enc.bin"
    # Pasa la longitud de su clave, su clave y la firma cifrada: ( #d || d || e_k(s))
    wc -l ./Claves/$surname"ECpub.pem" | cut -f 1 -d " " > $msg
    cat ./Claves/$surname"ECpub.pem" ./Resultados/"sgnB_enc.bin" >> $msg
# Alice
    # Leemos la longitud #d
    num=`cat $msg | head -n 1`
    # Lee la clave de Bob: d = g^b
    cat $msg | tail -n +2 | head -n $num > $pubB
    # Lee la firma cifrada de Bob: e_k(s)
    cat $msg | tail -n +$(($num+2)) > $sgn
    # Calcula la clave compartida: k = d^a = g^(ab)
    openssl pkeyutl -derive -passin pass:$passwd -inkey ./Claves/$name"ECpriv.pem" -peerkey $pubB -out $key
    # Descifra la firma: d_k(e_k(s))
    openssl enc -d $mode -pass file:$key -in $sgn -out ./Resultados/"sgnB_dec.bin"
    # Verifica que el mensaje lo ha firmado Bob
    openssl dgst -sha256 -verify ./Claves/$surname"DSApub.pem" -signature ./Resultados/"sgnB_dec.bin" <(cat ./Claves/$name"ECpub.pem" $pubB)
    # Firma (d || c): t = sgn_A (d || c)
    openssl dgst -sha256 -passin pass:$passwd -sign ./Claves/$name"DSApriv.pem" -out ./Resultados/"sgnA.bin" <(cat $pubB ./Claves/$name"ECpub.pem")
    # Cifra la firma: e_k(t)
    openssl enc $mode -pass file:$key -in ./Resultados/"sgnA.bin" -out ./Resultados/"sgnA_enc.bin"
    # Pasa la firma cifrada: e_k(t)
    cat ./Resultados/"sgnA_enc.bin" > $msg
# Bob
    # Lee la firma cifrada de Alice: e_k(t)
    cat $msg > $sgn
    # Descifra la firma: d_k(e_k(t))
    openssl enc -d $mode -pass file:$key -in $sgn -out ./Resultados/"sgnA_dec.bin"
    # Verifica que el mensaje lo ha firmado Alice
    openssl dgst -sha256 -verify ./Claves/$name"DSApub.pem" -signature ./Resultados/"sgnA_dec.bin" <(cat ./Claves/$surname"ECpub.pem" $pubA)

# Borra archivos temporales de los mensajes entre Alice y Bob
rm $msg $pubA $pubB $sgn

# Creando archivos para ver los valores
for i in $(ls ./Resultados/sgn*.bin | cut -f 2 -d ".")
    do
        xxd ./$i".bin" > ./$i".txt"
    done

