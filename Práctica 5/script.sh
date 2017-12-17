#! /bin/bash

# Directorios que contendrán los archivos
mkdir -p Resultados Gráficas

sample=${1:-10}
text=${2:-"Texto de prueba"}
last=${3:-3}
first=${4:-1}
increment=${5:-1}

random="Resultados\random"
linear="Resultados\linear"

for i in `seq $first $increment $last`
    do
        touch $random$i".csv" 2> $random$i".csv"
        touch $linear$i".csv" 2> $linear$i".csv"

        for j in `seq $sample`
            do
                echo "Prueba $j de $i ceros"
                ./functions.sh $text $i $random$i".csv" $linear$i".csv"
            done
    done




