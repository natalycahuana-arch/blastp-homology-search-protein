#Segundo script
#!/bin/bash
OUTDIR="descarga_fastas_mega"
mkdir -p "$OUTDIR"
Lista=(NP_001154368.1 NP_001185099.1) #ejemplos
for ACC in "${Lista[@]}"; do
        OUT="${OUTDIR}/${ACC}_homologos_control.fasta"
	#si la ubicación del archivo de entrada es
	CSV="/mnt/d/prueba/resultadoblast/${ACC}_blast_filtrado_5especies.csv"
	echo "Ver variable: $CSV"
	echo "separar columna de ACC_homologo, n°3"
	cut -d',' -f3 "$CSV" | while read acc; do
		echo "limpiar ACC"
		clean_acc=$(echo "$acc" | sed 's/^ref|//; s/^gb|//; s/^emb|//; s/^dbj|//; s/^sp|//; s/|$//')
		echo "$clean_acc"
		echo "Descargar fasta"
		fasta=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=protein&id=${clean_acc}&rettype=fasta&retmode=text")
		if echo "$fasta" | grep -q "^>"; then
        		echo "$fasta" >> "$OUT"
		else
        		echo "No se pudo descargar $clean_acc"
		fi
		sleep 1
	done
	control_file="/mnt/d/prueba/descargafastas/ACCdescargas/${ACC}_control.fasta"
	if [[ -f "$control_file" ]]; then
        	echo "Añadiendo control: $control_file"
        	cat "$control_file" >> "$OUT"
	else
        	echo "Control no encontrado para $ACC"
    	fi
    	echo "Archivo final: $OUT"
done
