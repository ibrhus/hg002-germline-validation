#!/usr/bin/env bash
# Per-exon coverage for selected genes (MANE Select CDS ±10 bp)
# Usage: ./exon_coverage.sh RORA HCRT CRY1 DBP
set -euo pipefail
GTF=ref/gencode.v49.basic.annotation.gtf.gz
GENES="${*:-RORA HCRT CRY1 DBP}"
mkdir -p qc/exons
PAT=$(echo $GENES | sed 's/ /|/g')

# chrom start end gene_exonN_strand  (0-based BED, ±10 bp)
zcat $GTF | awk -F'\t' -v pat="^($PAT)$" 'BEGIN{OFS="\t"}
  $3=="CDS" && $9 ~ /tag "MANE_Select"/ {
    match($9, /gene_name "[^"]+"/); g=substr($9, RSTART+11, RLENGTH-12);
    if (g !~ pat) next;
    match($9, /exon_number [0-9]+/); e=substr($9, RSTART+12, RLENGTH-12);
    print $1, $4-1-10, $5+10, g"_exon"e"_"$7 }' | sort -k1,1 -k2,2n > qc/exons/exons.bed

mosdepth -t 4 -n --by qc/exons/exons.bed --thresholds 10,20 qc/exons/ex bam/HG002.md.bam
bedtools nuc -fi ref/GRCh38.fa -bed qc/exons/exons.bed | cut -f4,6 | tail -n +2 > qc/exons/gc.txt

# Minimum depth per exon
samtools depth -a -b qc/exons/exons.bed bam/HG002.md.bam > qc/exons/depth.txt
awk 'BEGIN{OFS="\t"} NR==FNR {s[NR]=$2; e[NR]=$3; c[NR]=$1; n[NR]=$4; N=NR; next}
     {for(i=1;i<=N;i++) if($1==c[i] && $2>s[i] && $2<=e[i]) { if(!(i in m) || $3<m[i]) m[i]=$3 }}
     END{for(i=1;i<=N;i++) print n[i], m[i]}' qc/exons/exons.bed qc/exons/depth.txt > qc/exons/min.txt

echo -e "exon\tchr:start-end\tbp\tmean\tmin\tpct>=20x\tGC%"
paste <(zcat qc/exons/ex.regions.bed.gz) <(zcat qc/exons/ex.thresholds.bed.gz | grep -v '^#') | \
awk 'BEGIN{OFS="\t"} NR==FNR{gc[$1]=$2; next} FILENAME==ARGV[2]{mn[$1]=$2; next}
  {L=$3-$2; p=100*$11/L; printf "%s\t%s:%d-%d\t%d\t%.0f\t%s\t%.1f\t%.0f\n",
     $4, $1, $2+1, $3, L, $5, mn[$4], p, 100*gc[$4]}' qc/exons/gc.txt qc/exons/min.txt - | \
  sort -t$'\t' -k6,6n | tee qc/exons/exon_coverage.tsv | awk -F'\t' '$6<100'
echo "(only exons with <100% of bases >=20x shown; full table: qc/exons/exon_coverage.tsv)"
