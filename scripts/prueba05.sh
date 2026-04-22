#!/bin/bash
# Script 05
# Align the fastas
# ./scrips/prueba05.sh /home/daniela/GSM/Stephanosporaceae/BDD/concatenados
#####################################################
#Telegram bot
/bin/bash telegram_bot.sh
#####################################################

DIR="$1"

#Validar la carpeta. existe?
if [[ -z $DIR ]]; then
    echo "no se ha indicado la carpeta"
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
echo "¿Que archivo se va a alinear?"
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
    OUTPUT="alineamientos/${BASENAME}_align.fasta"
fi

#crear el directorio de output
mkdir -p "$(dirname "$OUTPUT")"
> "$OUTPUT"
TOTAL=0

#Concatenar los fastas ahora si
#validar que ninguno este vacio 
for FILE in "${SELECTED[@]}"; do
    if [[ ! -s "$FILE" ]]; then
        echo "$FILE esta vacio"
        tg_send "Tu cosa tiene un error"
        continue
    fi
    mafft --localpair --maxiterate 1000000 "$FILE" > "$OUTPUT"
done

echo "E alineamiento fue exitoso y está en $OUTPUT"
tg_send "Ya esta tu cosa: $OUTPUT"



