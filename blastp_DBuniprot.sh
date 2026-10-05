#!/bin/bash
mkdir -p /mnt/d/prueba/descargafastas/ACCdescargas
mkdir -p /mnt/d/prueba/blast/newcolumnaespecie/filtromejor
mkdir -p /mnt/d/prueba/resultadoblast
Lista=(O04590 Q8H1M0)
for ACC in "${Lista[@]}"; do
	curl -s "https://rest.uniprot.org/uniprotkb/$ACC.fasta" > /mnt/d/prueba/descargafastas/ACCdescargas/${ACC}_control.fasta
	if [ ! -s /mnt/d/prueba/descargafastas/ACCdescargas/${ACC}_control.fasta ]; then
    		echo "Error: No se pudo descargar la secuencia FASTA para $ACC"
    		exit 1
	fi
	echo "Descargando $ACC..."
	echo "Guardada en: ~/mnt/d/prueba/descargafastas/ACCdescargas/${ACC}_control.fasta"
	#Nombre / descripción de la proteína ACC
	DESC=$(grep "^>" /mnt/d/prueba/descargafastas/ACCdescargas/${ACC}_control.fasta | sed 's/^>[^ ]* //' | sed 's/ OS=.*$//' | sed 's/^ *//; s/ *$//')
	echo "Esta completando DESC = '$DESC'"
	echo "Buscando con BLAST..."
	#BLAST
	blastp -query /mnt/d/prueba/descargafastas/ACCdescargas/${ACC}_control.fasta \
	       -remote \
	       -db nr \
	       -entrez_query "txid4686[ORGN] OR txid29780[ORGN] OR txid3494[ORGN] OR txid59895[ORGN] OR txid3747[ORGN]" \
	       -out /mnt/d/prueba/blast/${ACC}_blast.csv \
	       -evalue 1e-5 \
	       -outfmt "10 qseqid sseqid pident qcovs length evalue bitscore stitle"
	       echo "Listo. Mira los resultados:"
	cat /mnt/d/prueba/blast/${ACC}_blast.csv
	#Columna adicional de especie
	awk -F',' 'BEGIN{OFS=","} {
            stitle ="" 
	    	for (i=8; i<=NF; i++) {stitle=(stitle==""? $i:stitle","$i)}
            if (match(stitle, /\[([^\]]+)\]/, arr)) {species = arr[1]}
            else {species="UnKnown"}
	    print $1,species,$2,$3,$4,$5,$6,$7,"\"" stitle "\"" 
        }' /mnt/d/prueba/blast/${ACC}_blast.csv > /mnt/d/prueba/blast/newcolumnaespecie/${ACC}_blastE.csv
	echo "Listo resultados + nueva fila"
	cat /mnt/d/prueba/blast/newcolumnaespecie/${ACC}_blastE.csv
	#Filtrado por %ID, coverage, descripción
	awk -F',' -v desc="$DESC" 'BEGIN{OFS=","}
	{
	    cspecies=$2
	    stitle=$9 
	    newstitle=stitle
	    sub(/ *\[[^]]+\]$/, "", newstitle)
	    pident=$4+0 
	    qcovs=$5+0
	    #Filtrado por %ID (PIDENT) y coverage (QCOVS)
	    if (!(cspecies in best_other)||
		(pident>best_pident[cspecies])||
                (pident==best_pident[cspecies] && qcovs>best_qcovs[cspecies])) {
			best_other[cspecies] = $0; best_pident[cspecies] = pident; best_qcovs[cspecies]  = qcovs
	    }
	    #Filtrado 
	    if (index(tolower(desc),tolower(newstitle))>0) {best_match[cspecies]=$0}
	}
	END {
	    for (s in best_match) {print best_match[s]}
	    for (s in best_other) {if (!(s in best_match)) {print best_other[s]}}
	}' /mnt/d/prueba/blast/newcolumnaespecie/${ACC}_blastE.csv > /mnt/d/prueba/blast/newcolumnaespecie/filtromejor/${ACC}_blast_filtrado.csv
	echo "FILTRADO"
	cat /mnt/d/prueba/blast/newcolumnaespecie/filtromejor/${ACC}_blast_filtrado.csv
	awk -F',' -v OFS=',' -v desc="$DESC" '
	{ gsub(/^ +| +$/, "", $2)             
	    especie = tolower($2)            
	    if (especie=="fragaria x ananassa" ||
      	        especie=="mangifera indica" ||
      	        especie=="asparagus officinalis" ||
                especie=="ficus carica" ||
                especie=="cynara cardunculus var. scolymus")
	    	{print $0, "\""desc"\""}
	}' /mnt/d/prueba/blast/newcolumnaespecie/filtromejor/${ACC}_blast_filtrado.csv > /mnt/d/prueba/resultadoblast/${ACC}_blast_filtrado_5especies.csv
	echo "Filtrado por 5 especies completado: ${ACC}_blast_filtrado_5especies.csv"
	cat /mnt/d/prueba/resultadoblast/${ACC}_blast_filtrado_5especies.csv
done
