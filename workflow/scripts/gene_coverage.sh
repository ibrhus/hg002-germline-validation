#!/usr/bin/env bash
# Per-gene coverage of the clock/sleep panel (MANE CDS ±10 bp)
set -euo pipefail
mosdepth -t 8 -n --by beds/panel_named.bed --thresholds 10,20,30 qc/panel bam/HG002.md.bam
echo -e "gene\tbp\tmean_depth\tpct_ge10x\tpct_ge20x\tpct_ge30x"
paste <(zcat qc/panel.regions.bed.gz) <(zcat qc/panel.thresholds.bed.gz | grep -v '^#') | \
awk 'BEGIN{OFS="\t"} {g=$4; L=$3-$2; bp[g]+=L; d[g]+=$5*L; t10[g]+=$10; t20[g]+=$11; t30[g]+=$12}
  END {for (g in bp) printf "%s\t%d\t%.0f\t%.1f\t%.1f\t%.1f\n", g, bp[g], d[g]/bp[g],
       100*t10[g]/bp[g], 100*t20[g]/bp[g], 100*t30[g]/bp[g]}' | sort -k5,5n | tee qc/panel_gene_coverage.tsv
