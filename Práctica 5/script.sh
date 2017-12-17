#! /bin/bash

# Directorios que contendrán los archivos
mkdir -p Resultados Gráficas

sample=${1:-10}                         # Primer parámetro: número de muestras, por defecto 10
text=${2:-"Texto de prueba"}            # Segundo parámetro: texto de entrada, por defecto "Texto de prueba"
last=${3:-3}                            # Tercer parámetro: último valor, por defecto 3
first=${4:-1}                           # Cuarto parámetro: primer valor, por defecto 1
increment=${5:-1}                       # Quinto parámetro: incremento entre valores, por defecto 1

random="Resultados/random"
linear="Resultados/linear"

# Bucle de los valores
for i in `seq $first $increment $last`
    do
        # Inicializamos vacíos los archivos de resultados
        touch $random$i".csv" 2> $random$i".csv"
        touch $linear$i".csv" 2> $linear$i".csv"

        # Bucle de las muestras
        for j in `seq $sample`
            do
                #echo "Prueba $j de $i ceros"        # Para visualizar el progreso
                ./functions.sh "$text" $i $random$i".csv" $linear$i".csv"
            done
    done

