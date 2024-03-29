#! /bin/bash

# Parámetros del programa:
text=${1:-"Texto de prueba"}        # Primer parámetro: texto de entrada, por defecto "Texto de prueba"
b=${2:-103}                         # Segundo parámetro: número de 0's que deben aparecer al principio, por defecto "103"
output1=${3:-random.csv}            # Tercer parámetro: archivo de salida del método aleatorio, por defecto "random.csv"
output2=${4:-linear.csv}            # Cuarto parámetro: archivo de salida del método lineal, por defecto "linear.csv"

# Máscaras a usar
mask=FFFFFFFF                       # Máscara completa
null=00000000                       # Máscara vacía

# Tamaño con el que trabajaremos
b_mask=32                           # En bits
h_mask=$(($b_mask>>2))              # En dígitos hexadecimales
B_mask=$(($h_mask>>1))              # En bytes

# Tamaño de nuestra máscara
b_My_Mask=256                       # En bits
h_My_Mask=$(($b_My_Mask>>2))        # En dígitos hexadecimales
B_My_Mask=$(($h_My_Mask>>1))        # En bytes

# Creamos la máscara de b_mask en b_mask bits
for i in `seq $b_mask $b_mask $b_My_Mask`
    do
        # Si índice es menor que b, van a quedar todo 0's después del desplazamiento, le asignamos la máscara vacía
        if (( $i < $b ))
        then
            aux=$mask

        # Si el índice anterior es mayor que b, van a quedar todo F's después del desplazamiento, le asignamos la máscara completa
        elif (( $(($i-$b_mask)) > $b ))
        then
            aux=$null

        # Si no, desplazamos la máscara completa i-b posiciones 
        else
            aux=`echo "obase=16; $((($((0x$mask)) << $(($i-$b))) & $((0x$mask))))" | bc`
        fi

        # Estamos construyendo la máscara al revés, del valor más significativo al menos significativo
        My_Mask=$My_Mask$aux
    done

# Función de validación, comprobamos de h_mask en h_mask cifras hexadecimales
valid_Hash(){
    value=true

    for i in `seq $h_mask $h_mask $h_My_Mask`
        do
            # Cortamos la máscara y el hash en cachos
            submask=`cut -c $((i-h_mask+1))-$i <(echo $My_Mask)`
            subhash=`cut -c $((i-h_mask+1))-$i <(echo $Hash)`

            # Los comparamos
            if (( $(($((0x$subhash)) & $((0x$submask)))) != 0 ))
            then
                value=false
            fi
        done
}

# Función para incrementar en 1 un número hexadecimal enorme representado en un string
increment_hex(){
    value=$1
    add="1"
    increment=''
    i=$h_My_Mask

    # Mientras haya que sumar:
    while (( $add != 0 ))
        do
            # Cortamos el valor en cachos
            subvalue=`cut -c $((i-h_mask+1))-$i <(echo $value)`

            # Sumamos y tomamos accarreo si es necesario
            subvalue=`echo "obase=16; $(($((0x$subvalue))+$add))" | bc`
            add=`echo "obase=16; $(($((0x$subvalue)) >> $b_mask))" | bc`

             # Si hay acarreo, cambiamos subvalue por la máscara vacía
            if (( $add != 0 ))
            then
                subvalue=$null

            # Si no hay acarreo:
            else
                # Completamos hasta tener una cadena de $hmask caracteres
                while [[ `cut -c $h_mask- <(echo $subvalue)` = "" ]]
                    do
                        subvalue="0"$subvalue
                    done
            fi

            # Concatenamos
            increment=$subvalue$increment

            let i=i-$h_mask

            # Si hemos recorrido toda la cadena, paramos
            if (( $i == 0))
            then
                add=0
            fi
        done

    # Cuando hayamos terminado de sumar, si no hemos recorrido toda la cadena
    if (( $i != 0))
    then
        # Cortamos el resto
        subvalue=`cut -c 1-$i <(echo $value)`

        # Concatenamos
        increment=$subvalue$increment
    fi
}

# Leemos n bytes de /dev/urandom (en hexadecimal):
nonce=`hexdump -vn $B_My_Mask -e '/1 "%02X"' /dev/urandom`

# Calculamos el id
id=$text$nonce

# Inicializamos el contador
cont=1

# Primer valor de la función aleatoria
x=`hexdump -vn $B_My_Mask -e '/1 "%02X"' /dev/urandom`
# Primer valor de la función lineal
y=$x

#Calculamos el hash
Hash=`openssl dgst -sha256 <<< $id$x | cut -d '=' -f 2 | tr '[:lower:]' '[:upper:]'`

# Comprobamos si nos vale
valid_Hash

while [ $value == false ]
    do
        # Siguiente valor de la función aleatoria
        x=`hexdump -vn $B_My_Mask -e '/1 "%02X"' /dev/urandom`

        # Calculamos el hash
        Hash=`openssl dgst -sha256 <<< $id$x | cut -d '=' -f 2 | tr '[:lower:]' '[:upper:]'`

        # Comprobamos si nos vale
        valid_Hash

        # Incrementamos el contador
        let cont=cont+1
    done

# Escribimos los valores en el archivo correspondiente
echo $id, $x, $Hash, $cont >> $output1

# Reseteamos el contador
cont=1

#Calculamos el hash
Hash=`openssl dgst -sha256 <<< $id$y | cut -d '=' -f 2 | tr '[:lower:]' '[:upper:]'`

# Comprobamos si nos vale
valid_Hash

while [ $value == false ]
    do
        # Siguiente valor de la función lineal
        increment_hex $y
        y=$increment

        # Calculamos el hash
        Hash=`openssl dgst -sha256 <<< $id$y | cut -d '=' -f 2 | tr '[:lower:]' '[:upper:]'`

        # Comprobamos si nos vale
        valid_Hash

        # Incrementamos el contador
        let cont=cont+1
    done

# Escribimos los valores en el archivo correspondiente
echo $id, $y, $Hash, $cont >> $output2

