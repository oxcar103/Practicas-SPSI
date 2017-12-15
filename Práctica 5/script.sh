#! /bin/bash

text=${1:-"Texto de prueba"}    # Primer parámetro: texto de entrada, por defecto "Texto de prueba"
b=${2:-103}                     # Segundo parámetro: número de 0's que deben aparecer al principio, por defecto "103"
output1=${3:-random.csv}        # Tercer parámetro: archivo de salida del método aleatorio, por defecto "random.csv"
output2=${4:-linear.csv}        # Cuarto parámetro: archivo de salida del método lineal, por defecto "linear.csv"
n_mask=32                       # Con cuantos bits vamos a trabajar
mask=FFFFFFFF                   # Máscara completa
null=00000000                   # Máscara vacía
n_My_Mask=256                   # Tamaño de nuestra máscara

# Creamos la máscara de n_mask en n_mask bits
for i in `seq $n_mask $n_mask $n_My_Mask`
    do
        # Si índice es menor que b, van a quedar todo 0's después del desplazamiento, le asignamos la máscara vacía
        if (( $i < $b ))
        then
            aux=$mask

        # Si el índice anterior es mayor que b, van a quedar todo F's después del desplazamiento, le asignamos la máscara completa
        elif (( $(($i-$n_mask)) > $b ))
        then
            aux=$null

        # Si no, desplazamos la máscara completa i-b posiciones 
        else
            aux=`echo "obase=16; $((($((0x$mask)) << $(($i-$b))) & $((0x$mask))))" | bc`
        fi

        # Estamos construyendo la máscara al revés, del valor más significativo al menos significativo
        My_Mask=$My_Mask$aux
    done

valid_Hash(){
    value=true

    for i in `seq $n $n $m`
        do
            submask=`cut -c $(($i-n+1))-$i <(echo $My_Mask)`
            subhash=`cut -c $(($i-n+1))-$i <(echo $Hash)`

            if (( $(($((0x$subhash)) & $((0x$submask)))) != 0 ))
            then
                value=false
            fi
        done

    return $value
}

