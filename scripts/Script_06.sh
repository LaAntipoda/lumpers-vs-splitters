#!/bin/bash
# Script 06
# IQ3 tree
# ./Script_06.sh ../alineamientos
#####################################################
#Telegram bot
/bin/bash telegram_bot.sh
#####################################################

DIR="$1"

#Validar la carpeta. existe?
if [[ -z $DIR ]]; then
    echo "no se ha indicado la carpeta"
    tg_send "Tu cosa tiene un error"
    exit 0
fi

#contiene fastas?
#creamos una variable con los nombres de los archivos que terminan en .fasta
mapfile -t FASTAS < <(find "$DIR" -maxdepth 1 -name "*.fasta" | sort)
# contamos el numero de archivos en FASTAS
if [[ ${#FASTAS[@]} -eq 0 ]]; then
    echo "no se encontraron archivos .fasta"
    tg_send "Tu cosa tiene un error"
    exit 0
fi

#si si mostrar los nombres en un indice bien nice
# ! indice
# # cantidad de elementos
echo "============================="
for i in "${!FASTAS[@]}"; do
#es util contar el numero de secuencias de cada archivo na mas para saber
    COUNTSEQS=$(grep -c "^>" "${FASTAS[$i]}" 2>/dev/null || echo 0)
    printf "  [%d] %s  (%d secuencias)\n" "$((i+1))" "$(basename "${FASTAS[$i]}")" "$COUNTSEQS"
done
echo "============================="

#Que permita seleccionar del menu
echo "¿Que alineamiento quieres usar?"
echo "Recuerda que el archivo de particiones debe llamarse exactamente igual _partitions.nex"
read -rp "> " SELECCION

#Seleccion
SELECTED=()
for NUM in $SELECCION; do
    #si el numero dado no esta en el menu
    if ! [[ "$NUM" =~ ^[0-9]+$ ]] || (( NUM < 1 || NUM > ${#FASTAS[@]} )); then
        echo "no valido"
        continue
    fi
    SELECTED+=("${FASTAS[$((NUM-1))]}")
done
#si es 0
if [[ ${#SELECTED[@]} -eq 0 ]]; then
    echo "seleccione un archivo"
    tg_send "Tu cosa tiene un error"
    exit 0
fi

#nombre del archivo output
if [[ ${#FASTAS[@]} -gt 0 ]]; then
    BASENAME=$(basename "${FASTAS}" .fasta)
    OUTPUT="alineamientos/IQ3_out/${BASENAME}_iq3.fasta"
fi

#crear el directorio de output
mkdir -p "$(dirname "$OUTPUT")"
> "$OUTPUT"
TOTAL=0

#validar que ninguno este vacio 
for FILE in "${SELECTED[@]}"; do
    if [[ ! -s "$FILE" ]]; then
        echo "$FILE esta vacio"
        continue
    fi
    iqtree2 -s  "$FILE" -spp "${DIR}/${BASENAME}_partitions.nex" -pre "$OUTPUT" -bb 100000 -alrt 1000
done

echo "El arbol fue exitoso y está en $OUTPUT"
tg_send "Ya esta tu cosa: $OUTPUT"


#falta que pida las particiones 

