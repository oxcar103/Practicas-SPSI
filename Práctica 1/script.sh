#! /bin/bash

# Archivo de 0's
dd if=/dev/zero of=input.bin bs=128 count=1 

# Archivo de 0's con un 1
cat input.bin | head -c 2 > input1.bin && printf '\100' >> input1.bin && cat input.bin | tail -c 125 >> input1.bin

# Clave
touch clave

# Directorio que contendrá los archivos
mkdir Resultados

# Codificar con clave débil y semi-débil usando los modos ECB, CBC y OFB de DES.
for key in "0101010101010101" "011F011F010E010E"
    do
        for mode in "des-ecb" "des-cbc" "des-ofb"
            do
                if [ $key == "0101010101010101" ]
                    then
                    sec="weak"
                else
                    sec="semiweak"
                fi

                openssl enc -$mode -K $key -iv 67 -in input.bin -out ./Resultados/input_$mode"_"$sec.bin
                openssl enc -$mode -K $key -iv 67 -in input1.bin -out ./Resultados/input1_$mode"_"$sec.bin
            done
    done

# Codificar con la clave generada usando los modos ECB y CBC de DES, AES-128 y AES-256.
for mode in "des-ecb" "des-cbc" "aes-128-ecb" "aes-128-cbc" "aes-256-ecb" "aes-256-cbc"
    do
        openssl enc -$mode -k clave -iv 67 -in input.bin -out ./Resultados/input_$mode.bin
        openssl enc -$mode -k clave -iv 67 -in input1.bin -out ./Resultados/input1_$mode.bin
    done

