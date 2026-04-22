#!/bin/bash
# Script 07
# mPTP inference

# Options to remember
# --ml --multi 
# ML estimate of the delimitation using the mPTP model.

# --mcmc  positive integer --multi 
# Computing support values by taking the specified number of MCMC samples (delimitations) using the mPTP model.

#This script asks for a tree.newick a fasta alignment and an outrgroup list 
# ./Script_07.sh ../alineamientos/IQ3_out/

#####################################################
#Telegram bot
/bin/bash telegram_bot.sh
#####################################################

DIR="$1"

# Validar la carpeta
if [[ -z $DIR ]]; then
    echo "no se ha indicado la carpeta"
    exit 1
fi

# ─────────────────────────────────────────
# ÁRBOL (.contree)
# ─────────────────────────────────────────
mapfile -t ARBOLES < <(find "$DIR" -maxdepth 1 -name "*.contree" | sort)
if [[ ${#ARBOLES[@]} -eq 0 ]]; then
    echo "no se encontraron archivos .contree"
    tg_send "Tu cosa tiene un error"
    exit 1
fi

echo "============================="
echo "  ÁRBOLES DISPONIBLES"
echo "============================="
for i in "${!ARBOLES[@]}"; do
    printf "  [%d] %s  (%d secuencias)\n" "$((i+1))" "$(basename "${ARBOLES[$i]}")"
done
echo "============================="

echo "¿Qué árbol consenso se va a utilizar?"
read -rp "> " SELECCION

SELECTED=()
for NUM in $SELECCION; do
    if ! [[ "$NUM" =~ ^[0-9]+$ ]] || (( NUM < 1 || NUM > ${#ARBOLES[@]} )); then
        echo "[$NUM] no válido, se omite"
        continue
    fi
    SELECTED+=("${ARBOLES[$((NUM-1))]}")
done

if [[ ${#SELECTED[@]} -eq 0 ]]; then
    echo "no se seleccionó ningún árbol válido"
    tg_send "Tu cosa tiene un error"
    exit 1
fi

# ─────────────────────────────────────────
# ALINEAMIENTO (.fasta) no siempre necesario
# ─────────────────────────────────────────
#mapfile -t ALIGN < <(find "$DIR" -maxdepth 1 -name "*.fasta" | sort)   # BUG FIX: era .contree
#if [[ ${#ALIGN[@]} -eq 0 ]]; then
#    echo "no se encontraron archivos .fasta"
#    exit 1
#fi

#echo "============================="
#echo "  ALINEAMIENTOS DISPONIBLES"
#echo "============================="
#for i in "${!ALIGN[@]}"; do
#    COUNTSEQS=$(grep -c "^>" "${ALIGN[$i]}" 2>/dev/null || echo 0)
#    printf "  [%d] %s  (%d secuencias)\n" "$((i+1))" "$(basename "${ALIGN[$i]}")" "$COUNTSEQS"
#done
#echo "============================="

#echo "¿Qué alineamiento se va a utilizar?"
#read -rp "> " SELECCIONALIGN

#SELECTEDALIGN=()
#for NUM in $SELECCIONALIGN; do
#    if ! [[ "$NUM" =~ ^[0-9]+$ ]] || (( NUM < 1 || NUM > ${#ALIGN[@]} )); then
#        echo "[$NUM] no válido, se omite"
#        continue
#    fi
#    SELECTEDALIGN+=("${ALIGN[$((NUM-1))]}")
#done

#if [[ ${#SELECTEDALIGN[@]} -eq 0 ]]; then
#    echo "no se seleccionó ningún alineamiento válido"
#    exit 1
#fi

# ─────────────────────────────────────────
# OUTGROUP (.txt)
# ─────────────────────────────────────────
mapfile -t TXTFILES < <(find "$DIR" -maxdepth 1 -name "*.txt" | sort)
if [[ ${#TXTFILES[@]} -eq 0 ]]; then
    echo "no se encontraron archivos .txt para el outgroup"
    tg_send "Tu cosa tiene un error"
    exit 1
fi

echo "============================="
echo "  ARCHIVOS DE OUTGROUP (.txt)"
echo "============================="
for i in "${!TXTFILES[@]}"; do
    printf "  [%d] %s\n" "$((i+1))" "$(basename "${TXTFILES[$i]}")"
done
echo "============================="

echo "¿Qué archivo .txt contiene el outgroup?"
read -rp "> " SELECCIONTXT

if ! [[ "$SELECCIONTXT" =~ ^[0-9]+$ ]] || (( SELECCIONTXT < 1 || SELECCIONTXT > ${#TXTFILES[@]} )); then
    echo "selección de outgroup no válida"
    tg_send "Tu cosa tiene un error"
    exit 1
fi

OUTGROUP_FILE="${TXTFILES[$((SELECCIONTXT-1))]}"

# Leer el contenido completo del .txt (eliminar saltos de línea)
OUTGROUP=$(cat "$OUTGROUP_FILE" | tr '\n' ',' | sed 's/^[[:space:]]*,//;s/,[[:space:]]*$//;s/[[:space:]]*,[[:space:]]*/,/g')


if [[ -z "$OUTGROUP" ]]; then
    echo "el archivo de outgroup está vacío"
    tg_send "Tu cosa tiene un error"
    exit 1
fi

echo "Outgroup cargado: $OUTGROUP"

# ─────────────────────────────────────────
# OUTPUT
# ─────────────────────────────────────────
BASENAME=$(basename "${SELECTED}" .contree)   # BUG FIX: usaba ARBOLES en vez de SELECTED
OUTPUT="mptp_out/${BASENAME}_mptp"
mkdir -p "$(dirname "$OUTPUT")"

# ─────────────────────────────────────────
# EJECUTAR mPTP
# ─────────────────────────────────────────
for i in "${!SELECTED[@]}"; do
    FILETREE="${SELECTED[$i]}"
    #FILEALIGN="${SELECTEDALIGN[$i]:-${SELECTEDALIGN}}"  # empareja por índice, cae al primero si no hay par

    if [[ ! -s "$FILETREE" ]]; then
        echo "$FILETREE está vacío, se omite"
        tg_send "Tu cosa tiene un error"
        continue
    fi

    echo "Corriendo mPTP: $(basename "$FILETREE")"

    mptp --mcmc 50000000 \
         --multi \
         --mcmc_sample 1000000 \
         --mcmc_burnin 1000000 \
         --tree_file "$FILETREE" \
         --output_file "$OUTPUT" \
         --outgroup "$OUTGROUP" \
         --mcmc_runs 4
#         --minbr_auto "$FILEALIGN" \
done

echo "Análisis completado. Resultados en: $OUTPUT"
tg_send "Ya está tu cosa: $OUTPUT"
