#! /bin/bash

# Directorios que contendrán los archivos
mkdir -p Resultados Tablas

sample=${1:-10}                         # Primer parámetro: número de muestras, por defecto 10
text=${2:-"Texto de prueba"}            # Segundo parámetro: texto de entrada, por defecto "Texto de prueba"
last=${3:-103}                          # Tercer parámetro: último valor, por defecto 103
first=${4:-1}                           # Cuarto parámetro: primer valor, por defecto 1
increment=${5:-1}                       # Quinto parámetro: incremento entre valores, por defecto 1

random="./Resultados/random"
linear="./Resultados/linear"
g_random="./Tablas/random.txt"
g_linear="./Tablas/linear.txt"

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

# Bucle de los tablas (la estructura dependerá mucho de dónde se visualizará)
for i in $random $linear
    do
        # Separación en distintos archivos
        if [ "$i" == "$random" ]
        then
            graph=$g_random
        else
            graph=$g_linear
        fi

        # Cabecera
        echo -e "B \t|\t\t\t\tElements\t\t\t\t\t| Total\t| Average" > $graph

        # Separador
        echo -e "---------------------------------------------------------------------------------------------------------" >> $graph

        for j in `seq $first $increment $last`
            do
                # Reseteo
                sum=0
                mean=0
                elements=0
                msg="| $j \t|"

                for k in `cat $i$j".csv" | cut -d ',' -f 4 | tr -d ' '`
                    do
                        # Guardamos el valor para mostrarlo
                        msg=$msg" $k \t|"

                        # Lo sumamos al total
                        let sum=sum+$k
                        let elements=elements+1
                    done

                # Calculamos la media
                mean=`echo "scale=5; $sum/$elements" | bc -l`
                # Le ponemos el 0 nos sale menor que 1
                mean=${mean/#./0.}

                # Guardamos la suma y la media para mostrarlas
                msg=$msg" $sum \t| $mean \t|"

                # Volcamos la línea al archivo
                echo -e $msg >> $graph

                # Separador
                echo -e "---------------------------------------------------------------------------------------------------------" >> $graph
            done
    done

