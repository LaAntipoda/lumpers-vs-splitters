#!/bin/bash
# Script 03
# Remover secuencias duplicadas de un archivo .fasta
# Duplicates are identified by their nucleotide sequence (header is ignored).
# Unique sequences -> output file (default: unique.fasta)
# Duplicate sequences -> duplicadas.fasta
#
# ./Script_03.sh -i ../concatenados/*_concatenados.fasta

INPUT=""
OUTPUT="unique.fasta"
DUPLICADAS="duplicadas.fasta"

while getopts "i:o:" opt; do
    case $opt in
        i) INPUT="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
        *) echo "Usage: $0 -i input.fasta [-o unique.fasta]"; exit 1 ;;
    esac
done

if [ -z "$INPUT" ]; then
    echo "No se ha idicado el archivo"
    echo "Usage: $0 -i input.fasta [-o unique.fasta]"
    exit 1
fi

if [ ! -f "$INPUT" ]; then
    echo "ERROR: File not found: $INPUT"
    exit 1
fi

> "$OUTPUT"
> "$DUPLICADAS"

TOTAL=0
UNIQUE=0
DUPES=0

declare -A seen_hashes  # md5hash -> first header

process_record() {
    local header="$1"
    local seq="$2"

    [ -z "$header" ] && return

    TOTAL=$((TOTAL + 1))

    # Use md5 hash of the sequence as the array key
    local hash
    hash=$(echo "$seq" | md5sum | cut -d' ' -f1)

    if [ -z "${seen_hashes[$hash]+_}" ]; then
        seen_hashes["$hash"]="$header"
        printf "%s\n%s\n" "$header" "$seq" >> "$OUTPUT"
        UNIQUE=$((UNIQUE + 1))
    else
        local first="${seen_hashes[$hash]}"
        printf "%s\n%s\n" "$header" "$seq" >> "$DUPLICADAS"
        DUPES=$((DUPES + 1))
        echo "  DUPLICATE: $header"
        echo "    (same sequence as: $first)"
    fi
}

current_header=""
current_seq=""

while IFS= read -r line || [ -n "$line" ]; do
    if [[ "$line" == ">"* ]]; then
        process_record "$current_header" "$current_seq"
        current_header="$line"
        current_seq=""
    else
        current_seq="${current_seq}$(echo "$line" | tr -d ' \r' | tr '[:lower:]' '[:upper:]')"
    fi
done < "$INPUT"

# Process last record
process_record "$current_header" "$current_seq"

echo ""
echo "============================="
echo "  Total sequences read : $TOTAL"
echo "  Unique sequences     : $UNIQUE  -> '$OUTPUT'"
echo "  Duplicate sequences  : $DUPES  -> '$DUPLICADAS'"
echo "============================="
