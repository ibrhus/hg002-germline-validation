#!/usr/bin/env bash
# Build MANE Select CDS ±10 bp BED (exome-wide) + clock/sleep panel BEDs
set -euo pipefail
GTF=${1:-ref/gencode.v49.basic.annotation.gtf.gz}
OUT=${2:-beds}
mkdir -p $OUT/genes

PANEL="CLOCK BMAL1 BMAL2 NPAS2 PER1 PER2 PER3 CRY1 CRY2 NR1D1 NR1D2 RORA RORB RORC \
CSNK1D CSNK1E FBXL3 TIMELESS BHLHE40 BHLHE41 DBP NFIL3 TEF ADRB1 NPSR1 GRM1 HCRT HCRTR2 GAPVD1"

# MANE Select CDS, ±10 bp, chr1-22 (truth set), BED is 0-based
zcat $GTF | awk -F'\t' 'BEGIN{OFS="\t"}
  $3=="CDS" && $9 ~ /tag "MANE_Select"/ && $1 ~ /^chr([0-9]+)$/ {
    match($9, /gene_name "[^"]+"/); g=substr($9, RSTART+11, RLENGTH-12);
    s=$4-1-10; if (s<0) s=0; print $1, s, $5+10, g }' | \
  sort -k1,1V -k2,2n > $OUT/mane_cds10_named.bed

cut -f1-3 $OUT/mane_cds10_named.bed | bedtools merge > $OUT/mane_cds10.bed

: > $OUT/panel_named.bed
: > $OUT/strat.tsv
for g in $PANEL; do
  awk -v g=$g '$4==g' $OUT/mane_cds10_named.bed > $OUT/genes/$g.tmp
  if [ -s $OUT/genes/$g.tmp ]; then
    cut -f1-3 $OUT/genes/$g.tmp | bedtools merge > $OUT/genes/$g.bed
    cat $OUT/genes/$g.tmp >> $OUT/panel_named.bed
    printf "%s\t%s\n" "$g" "genes/$g.bed" >> $OUT/strat.tsv
  else
    echo "WARNING: $g not found in MANE Select CDS" >&2
  fi
  rm -f $OUT/genes/$g.tmp
done
cut -f1-3 $OUT/panel_named.bed | sort -k1,1V -k2,2n | bedtools merge > $OUT/panel.bed
printf "PANEL_ALL\tpanel.bed\nMANE_CDS10\tmane_cds10.bed\n" >> $OUT/strat.tsv

awk '{s+=$3-$2} END {printf "MANE CDS ±10bp: %.2f Mb\n", s/1e6}' $OUT/mane_cds10.bed
awk '{s+=$3-$2} END {printf "Panel: %.1f kb, %d intervals\n", s/1e3, NR}' $OUT/panel.bed
echo "Genes in panel: $(grep -vc -e PANEL_ALL -e MANE_CDS10 $OUT/strat.tsv)"

# hap.py stratification file with container paths (/w = project folder)
awk -v d=/w/$OUT 'BEGIN{OFS="\t"} {print $1, d"/"$2}' $OUT/strat.tsv > $OUT/strat_docker.tsv
