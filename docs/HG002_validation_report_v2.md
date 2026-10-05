# HG002 Exome – Validation Report v2

Date: 4 October 2026
Sample: GIAB HG002 (NA24385), Oslo University Hospital exome, Agilent SureSelect v5, Illumina paired-end
Reference: GRCh38 no-alt analysis set (GIAB)
Truth set: GIAB HG002 v4.2.1 (chr1–22), benchmark_noinconsistent.bed
Annotation: GENCODE v49 basic, MANE Select transcripts
Compute: de.NBI Cloud Bielefeld SimpleVM, 28 cores, 62 GB RAM

## 1. Changes from v1

| | v1 | v2 |
|---|---|---|
| Evaluation region | ≥20× coverage ∩ GIAB high-confidence regions (87.5 Mb, mostly outside capture targets) | MANE Select coding exons ±10 bp, chr1–22 (35.71 Mb) ∩ GIAB high-confidence regions |
| Calling region (DeepVariant) | ≥20× coverage | Tested: ≥20×; MANE CDS ±10 bp; MANE CDS ±100 bp |
| Gene-level results | none | 29-gene clock/sleep panel: per-gene recall and coverage |

## 2. Pipeline and versions

| Step | Tool | Version |
|---|---|---|
| Alignment | bwa mem | 0.7.19-r1273 |
| Sort, duplicate marking | samtools fixmate/sort/markdup | 1.24 |
| Coverage | mosdepth | conda (record version) |
| Caller 1 | DeepVariant, WES model | 1.6.1 |
| Caller 2 | GATK HaplotypeCaller + hard filter (QD<2, FS>60, MQ<40), no BQSR | 4.6.2.0 |
| Benchmarking | hap.py (xcmp), --pass-only, -T target regions, --stratification per gene | v0.3.12 |

Alignment QC (unchanged from v1): 75.2 M read pairs, 99.72% mapped, 98.96% properly paired, 4.8% duplicates.

## 3. Coverage of coding exons

| Metric | Value |
|---|---|
| MANE Select CDS ±10 bp (chr1–22) | 35.71 Mb |
| Of which ≥20× | 34.56 Mb (96.8%) |
| Not reaching 20× | 1.15 Mb (3.2%) |

## 4. Small-variant performance on MANE CDS ±10 bp

| Caller | Calling region | Type | Truth | FN | FP | Recall | Precision |
|---|---|---|---|---|---|---|---|
| DeepVariant | ≥20× only | SNP | 22,422 | 934 | 19 | 95.83% | 99.91% |
| DeepVariant | ≥20× only | INDEL | 746 | 91 | 9 | 87.80% | 98.66% |
| DeepVariant | CDS ±10 bp | SNP | 22,422 | 532 | 63 | 97.63% | 99.71% |
| DeepVariant | CDS ±10 bp | INDEL | 746 | 50 | 12 | 93.30% | 98.32% |
| **DeepVariant (final)** | **CDS ±100 bp** | **SNP** | **22,422** | **530** | **62** | **97.64%** | **99.72%** |
| **DeepVariant (final)** | **CDS ±100 bp** | **INDEL** | **746** | **54** | **16** | **92.76%** | **97.76%** |
| GATK HC | ≥20× only | SNP | 22,422 | 1,104 | 405 | 95.08% | 98.14% |
| GATK HC | ≥20× only | INDEL | 746 | 117 | 83 | 84.32% | 88.47% |

Fair caller comparison (same ≥20× calling region): DeepVariant had 21× fewer SNP false positives (19 vs 405) and higher indel recall (87.8% vs 84.3%).

### 4.1 Where the missed variants are (DeepVariant, ≥20× calling)

| Location of false negative | Count | Share |
|---|---|---|
| Outside ≥20× regions (not called) | 824 | 80% |
| Inside ≥20× regions (caller miss) | 209 | 20% |

Depth at missed positions (bases): 0×: 166; 1–9×: 495; 10–19×: 243; ≥20×: 446.

Interpretation: most false negatives come from capture coverage gaps, not caller errors. Calling outside the ≥20× regions recovered 402 SNPs and 41 indels, but tripled SNP false positives (19 → 63). Padding the calling region from ±10 to ±100 bp had no measurable effect.

## 5. Clock/sleep gene panel (29 genes, 63.9 kb MANE CDS ±10 bp)

### 5.1 Variant detection (DeepVariant, final configuration)

| Type | Truth | TP | FN | FP | Recall |
|---|---|---|---|---|---|
| SNP | 31 | 31 | 0 | 0 | 100% |
| INDEL | 1 | 0 | 1 | 0 | 0% |

Genes with ≥1 truth SNP: FBXL3 (1), GAPVD1 (1), GRM1 (4), HCRTR2 (1), NPAS2 (3), NPSR1 (1), PER1 (3), PER2 (1), PER3 (3), RORA (1), RORB (1), TIMELESS (5), among others. Several genes (e.g. DBP, HCRT, NFIL3, NR1D1, NR1D2, RORC, TEF) have no variant in HG002 within the CDS, so per-gene recall cannot be estimated for them. Coverage (5.2) is the relevant per-gene metric.

### 5.2 Per-gene coverage (MANE CDS ±10 bp)

Panel total: mean depth 182×; ≥10×: 99.90%; ≥20×: 99.24%; ≥30×: 98.33%. 25 of 29 genes have ≥98% of bases at ≥20×.

Genes below 98% at ≥20×:

| Gene | bp | Mean depth | ≥10× | ≥20× | ≥30× |
|---|---|---|---|---|---|
| RORA | 1,789 | 166 | 97.0% | 89.6% | 89.6% |
| HCRT | 433 | 98 | 100% | 94.0% | 85.9% |
| CRY1 | 1,998 | 191 | 100% | 95.4% | 93.4% |
| DBP | 1,055 | 95 | 99.0% | 95.6% | 88.2% |

All other panel genes: BHLHE41 98.1%, CSNK1D 98.1%, NR1D1 98.5%, PER1 98.9%, TIMELESS 99.9%. The other 20 genes have 100% at ≥20×: ADRB1, BHLHE40, BMAL1, BMAL2, CLOCK, CRY2, CSNK1E, FBXL3, GAPVD1, GRM1, HCRTR2, NFIL3, NPAS2, NPSR1, NR1D2, PER2, PER3, RORB, RORC, TEF.

## 6. Documented limitation: BHLHE41 in-frame insertion

| Item | Value |
|---|---|
| Variant | chr12:26122291 G>GGCGGCGGCA (9 bp in-frame insertion, GCG repeat) |
| Gene | BHLHE41 (DEC2), MANE CDS |
| Local depth | 20–33× |
| DeepVariant, ≥20× calling | Called 0/1, GQ 26, AD 20,6 (VAF 0.23) |
| DeepVariant, CDS ±10 bp | Not called (no record) |
| DeepVariant, CDS ±100 bp | Not called |
| GATK HC | Not called |

Interpretation: the evidence is weak and unstable. Only 6/26 reads support the insertion (expected VAF ~0.5), most likely because insertion-carrying reads align poorly to a GC-rich repeat. Detection is not reproducible across runs.
Statement for the validation file: sensitivity is reduced for in-frame insertions in GC-rich repeat regions. Variants in such regions with VAF <0.3 or GQ <30 need orthogonal confirmation (e.g. Sanger sequencing).

## 7. Conclusions

1. The final configuration is DeepVariant 1.6.1 (WES model), called on MANE CDS ±100 bp. On MANE coding exons ±10 bp it reached SNP recall 97.6% / precision 99.7% and INDEL recall 92.8% / precision 97.8%.
2. The main limit on sensitivity is capture coverage (3.2% of coding bases <20×), not the caller.
3. DeepVariant clearly outperforms GATK HaplotypeCaller with hard filters on this data.
4. Clock/sleep panel: all 31 truth SNPs detected with no false positives. Coverage ≥20× is 99.24% overall, with gaps in RORA, HCRT, CRY1 and DBP.

## 8. Open items for v3

- Find the uncovered exons in RORA, HCRT, CRY1 and DBP (per-exon coverage table).
- Report low-coverage calls (<20×) separately as "requires confirmation".
- Stratify with GIAB GRCh38 stratifications (GC content, low-complexity regions, segmental duplications).
- Coverage titration (downsampling to 50% / 25%).
- Optional: GATK with BQSR and separate SNP/indel filters, called on CDS ±100 bp.
- Wrap all steps in Snakemake/Nextflow and publish on GitHub.
