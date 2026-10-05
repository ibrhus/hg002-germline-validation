# HG002 Exome – Validation Report v1

Date: 4 October 2026
Sample: GIAB HG002 (NA24385), Oslo University Hospital exome, Agilent SureSelect v5, Illumina paired-end
Reference: GRCh38 no-alt analysis set (GIAB)
Truth set: GIAB HG002 v4.2.1 (chr1–22), benchmark_noinconsistent.bed
Compute: de.NBI Cloud Bielefeld SimpleVM, 28 cores, 62 GB RAM

## Pipeline and versions

| Step | Tool | Version |
|---|---|---|
| BAM → FASTQ | samtools collate/fastq | 1.24 |
| Alignment | bwa mem | 0.7.19-r1273 |
| Sort, duplicate marking | samtools fixmate/sort/markdup | 1.24 |
| Coverage | mosdepth | (conda, record with `mosdepth --version`) |
| Caller 1 | DeepVariant, WES model | 1.6.1 (Docker) |
| Caller 2 | GATK HaplotypeCaller + hard filter (QD<2, FS>60, MQ<40) | 4.6.2.0 |
| Benchmarking | hap.py (xcmp engine), --pass-only | v0.3.12 (Docker) |

No BQSR in this run.

## Sequencing and alignment QC

| Metric | Value |
|---|---|
| Read pairs | 75,193,388 |
| Mapped | 99.72% |
| Properly paired | 98.96% |
| Duplicates | 7,289,752 (4.8%) |
| Singletons | 0.16% |
| Region with ≥20× coverage | 94.92 Mb |
| Evaluated region (≥20× ∩ GIAB high-confidence) | 87.52 Mb |

## Small-variant performance (evaluated region, 87.5 Mb)

| Caller | Type | Truth | TP | FN | FP | Recall | Precision | F1 |
|---|---|---|---|---|---|---|---|---|
| DeepVariant 1.6.1 | SNP | 83,939 | 83,082 | 857 | 170 | 0.9898 | 0.9980 | 0.9939 |
| DeepVariant 1.6.1 | INDEL | 9,024 | 8,569 | 455 | 234 | 0.9496 | 0.9739 | 0.9616 |
| GATK HC 4.6.2 (hard filter) | SNP | 83,939 | 82,393 | 1,546 | 1,558 | 0.9816 | 0.9814 | 0.9815 |
| GATK HC 4.6.2 (hard filter) | INDEL | 9,024 | 8,280 | 744 | 933 | 0.9176 | 0.9005 | 0.9089 |

Additional quality indicators

| Metric | Truth | DeepVariant | GATK |
|---|---|---|---|
| SNP Ti/Tv | 2.41 | 2.32 | 2.30 |
| SNP het/hom ratio | 1.61 | 1.61 | 1.79 |
| INDEL het/hom ratio | 1.56 | 1.66 | 2.15 |

## Interpretation

- DeepVariant outperformed GATK on all metrics. False-positive SNPs were ~9× lower (170 vs 1,558), and indel F1 was 96.2% vs 90.9%.
- GATK's raised het/hom ratio (1.79 SNP, 2.15 indel vs truth 1.61/1.56) means most of its false positives are spurious heterozygous calls. These typically come from mapping artefacts, low-quality bases or off-target regions.
- The evaluated region (87.5 Mb) is much larger than the Agilent v5 target (~50 Mb). It includes flanks and off-target regions with uneven coverage, so recall here is conservative.

## Limitations of v1

- No BQSR; one hard-filter set for both SNPs and indels.
- Evaluation not restricted to capture targets.
- No stratification (GC content, low-complexity regions, segmental duplications).
- Single run; repeatability and coverage titration not yet tested.
- chrX/Y not evaluated (truth set covers chr1–22).

## Planned v2

1. Restrict to capture targets (Agilent v5 BED, or a RefSeq/GENCODE coding-exon BED ± 10 bp).
2. GATK: add BQSR (dbSNP, Mills/1000G indels), separate SNP/indel hard filters (indels: QD<2, FS>200, ReadPosRankSum<-20), or CNNScoreVariants.
3. hap.py with GIAB v3.x GRCh38 stratifications.
4. Coverage titration: downsample to 50%, 25% and 10%.
5. Clock/sleep gene panel: report per-gene recall.
