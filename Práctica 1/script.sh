#! /bin/bash

touch clave

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


for mode in "des-ecb" "des-cbc" "aes-128-ecb" "aes-128-cbc" "aes-256-ecb" "aes-256-cbc"
    do
        openssl enc -$mode -k clave -iv 67 -in input.bin -out ./Resultados/input_$mode.bin
        openssl enc -$mode -k clave -iv 67 -in input1.bin -out ./Resultados/input1_$mode.bin
    done
