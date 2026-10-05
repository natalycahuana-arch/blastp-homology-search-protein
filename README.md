# BLASTP Homology Search — Protein
Bash pipeline to search for homologous proteins in **5 species of interest**:
asparagus (*Asparagus officinalis*), fig (*Ficus carica*),
artichoke (*Cynara cardunculus*), strawberry (*Fragaria × ananassa*), and
mango (*Mangifera indica*).
These species can be replaced with any other set of species.
# Scripts: blastp_DBuniprot.sh / blastp_DBprotein.sh
## Pipeline workflow
1. **Downloads** the query protein FASTA sequence from NCBI or UniProt
2. **Remote BLASTP** against the NCBI `nr` database, restricted to the 5 species (taxIDs:
   3747, 59895, 3494, 29780, 4686)
3. **Species extraction** from each hit title (text in brackets)
4. **Deduplication by species**: keeps the best hit per species based on
   % identity and coverage; prioritizes hits with the same annotated function as the query
5. **Final filtering** by the 5 target species
## Scripts
| Script | Query sequence source | BLAST database |
|--------|----------------------|----------------|
| `blastp_DBprotein.sh` | NCBI (RefSeq, e.g. `NP_...`) | NCBI `nr` |
| `blastp_DBuniprot.sh` | UniProtKB (e.g. `O04590`) | NCBI `nr` |
## Requirements: curl, BLAST+ (blastp), gawk, and an internet connection
## Usage
1. Have a list of UniProt or Protein accessions ready
2. Insert this list into `Lista=(___________)` — each accession separated by spaces,
   not commas or semicolons, e.g.: `Lista=(P0CW77 Q9SUM5 O65570)`
3. Run in the terminal with `bash blastp_DBuniprot.sh` or `bash blastp_DBprotein.sh`
