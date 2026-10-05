#!/usr/bin/env bash
# SV (Manta + Truvari) and CNV (CNVkit) steps used in validation report v3.
# Run from the project directory. Envs: sv (manta), truvari, cnvkit, ngs (htslib/bcftools/bedtools).
set -euo pipefail
N=~/miniconda3/envs/ngs/bin
mkdir -p sv cnv/r3

# --- SV: Manta (exome mode, >=20x regions)
$N/bgzip -c qc/cov20.bed > sv/cov20.bed.gz && $N/tabix -f -p bed sv/cov20.bed.gz
conda run -n sv configManta.py --bam bam/HG002.md.bam --referenceFasta ref/GRCh38.fa \
  --exome --callRegions sv/cov20.bed.gz --runDir sv/manta
conda run -n sv sv/manta/runWorkflow.py -j 24
$N/bcftools view -f PASS sv/manta/results/variants/diploidSV.vcf.gz -Oz -o sv/HG002.manta.pass.vcf.gz
$N/tabix -f -p vcf sv/HG002.manta.pass.vcf.gz

# --- SV benchmark: Truvari vs GIAB v5.0q stvar, within benchmark ∩ >=20x
$N/bedtools intersect -a truth/HG002_GRCh38_v5.0q_stvar.benchmark.bed -b qc/cov20.bed \
  | sort -k1,1 -k2,2n | $N/bedtools merge > sv/eval_sv.bed
rm -rf sv/truvari_manta
conda run -n truvari truvari bench -b truth/HG002_GRCh38_v5.0q_stvar.vcf.gz -c sv/HG002.manta.pass.vcf.gz \
  --includebed sv/eval_sv.bed -o sv/truvari_manta --pctseq 0 --sizemin 50

# --- CNV: CNVkit single sample, flat male reference, captured CDS targets
$N/bedtools intersect -a beds/mane_cds10.bed -b qc/cov20.bed | sort -k1,1 -k2,2n | $N/bedtools merge > cnv/r3/targets.bed
conda run -n cnvkit cnvkit.py access ref/GRCh38.fa -o cnv/access.bed
conda run -n cnvkit cnvkit.py batch bam/HG002.md.bam -n -y -t cnv/r3/targets.bed -f ref/GRCh38.fa \
  --access cnv/access.bed --output-reference cnv/r3/flat_ref_male.cnn -d cnv/r3/ -p 16 --drop-low-coverage
conda run -n cnvkit cnvkit.py call cnv/r3/HG002.md.cns --sample-sex male --male-reference -o cnv/r3/HG002.call.cns

# --- CNV check against known exonic deletions >=10 kb (cnv/truth_dels10k.bed, see report v3 section 8)
bash scripts/cnv_eval.sh cnv/r3/HG002.call.cns
