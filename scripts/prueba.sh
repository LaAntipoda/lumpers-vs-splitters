#!/bin/bash
# Script 01
# validar los id de las secuencias mediante expresiones regulares
# el imput es un archivo sucio qe contiene IDs y metadata 

INPUT="$1"

#Validar el archivo
#existe?
if [[ -z $INPUT ]]; then
	echo "no se ha indicado el archivo"
	exit 0
fi

BASENAME=$(basename "$INPUT" .txt)
OUTPUT="out/"

# 01
# extraer los ID que hacen match y guardarlos en  BASENAME_id.txt
grep -oE '^[0-9]+\.\s+([A-Z0-9]+)\|([a-zA-Z0-9]+)' "$INPUT" | \
    sed 's/^[0-9]\+\.\s*//' | \
    cut -d'|' -f1 | \
    sort -u > "${OUTPUT}/${BASENAME}_id.txt"

EXTRACTED_COUNT=$(wc -l < "${OUTPUT}/${BASENAME}_id.txt")
echo "Extracted $EXTRACTED_COUNT unique IDs"

# 02
# Validar que BASENAME_id.txt es una lista completa

ORIGINAL_COUNT=$(wc -l < "$INPUT")

if [[ -z $INPUT ]]; then
    echo "no se ha indicado el archivo"
    exit 0
fi

if [ "$EXTRACTED_COUNT" -eq "$ORIGINAL_COUNT" ]; then
	echo "Expected $ORIGINAL_COUNT unique IDs"
    echo "Completo"
else
    echo "Expected $ORIGINAL_COUNT, got $EXTRACTED_COUNT"
    echo "Ya pelaste pa"
    #exit 0
fi

##########################

# 03 - Extraer secuencias FASTA por ID
#la base de datos ya existe 

INPUT="$1"
UNITE="/home/daniela/GSM/Stephanosporaceae/BDD/Unite/qiime_s/sh_refs_qiime_ver10_99_s_19.02.2025.fasta"
OUTPUT="out/"
BASENAME=$(basename "$INPUT" .txt)

# Validar la base de datos 
if [[ ! -f "$UNITE" ]]; then
    echo "no se ha indicado la base de datos"
    exit 0
fi

# 04
# Leer cada ID y buscar en FASTA
# indicar donde debe de anotar las secuencias encontradas
> "${OUTPUT}/${BASENAME}_seqs.fasta"

while IFS= read -r id; do
    awk -v id="$id" '
        /^>/ {
            if ($0 ~ "_" id "$") {
                print $0
                in_seq = 1
            } else {
                in_seq = 0
            }
        }
        in_seq && !/^>/ { print }
    ' "$UNITE" >> "${OUTPUT}/${BASENAME}_seqs.fasta"
done < "${OUTPUT}/${BASENAME}_id.txt"

FASTA_COUNT=$(grep -c "^>" "${OUTPUT}/${BASENAME}_seqs.fasta")
echo "Se extrajeron $FASTA_COUNT secuencias"
echo "guardadas en ${OUTPUT}/${BASENAME}_seqs.fasta"

exit 0
