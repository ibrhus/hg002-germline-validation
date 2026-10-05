# HG002 Exome – Validation Report v3

Date: 5 October 2026
Sample: GIAB HG002 (NA24385), Oslo University Hospital exome, Agilent SureSelect v5, Illumina paired-end
Reference: GRCh38 no-alt analysis set (GIAB)
Truth sets: GIAB HG002 v4.2.1 small variants (chr1–22), benchmark_noinconsistent.bed; GIAB HG002 v5.0q structural variants (stvar)
Annotation: GENCODE v49 basic, MANE Select transcripts
Compute: de.NBI Cloud Bielefeld SimpleVM, 28 cores, 62 GB RAM

## 1. Changes from v1 and v2

| | v1 | v2 |
|---|---|---|
| Evaluation region | ≥20× coverage ∩ GIAB high-confidence regions (87.5 Mb, mostly outside capture targets) | MANE Select coding exons ±10 bp, chr1–22 (35.71 Mb) ∩ GIAB high-confidence regions |
| Calling region (DeepVariant) | ≥20× coverage | Tested: ≥20×; MANE CDS ±10 bp; MANE CDS ±100 bp |
| Gene-level results | none | 29-gene clock/sleep panel: per-gene recall and coverage |

New in v3: structural-variant calling (Manta) benchmarked with Truvari against GIAB v5.0q (section 7); single-sample exome CNV calling (CNVkit) checked against known HG002 exonic deletions (section 8); the pipeline is wrapped in Snakemake.

## 2. Pipeline and versions

| Step | Tool | Version |
|---|---|---|
| Alignment | bwa mem | 0.7.19-r1273 |
| Sort, duplicate marking | samtools fixmate/sort/markdup | 1.24 |
| Coverage | mosdepth | conda (record version) |
| Caller 1 | DeepVariant, WES model | 1.6.1 |
| Caller 2 | GATK HaplotypeCaller + hard filter (QD<2, FS>60, MQ<40), no BQSR | 4.6.2.0 |
| Benchmarking | hap.py (xcmp), --pass-only, -T target regions, --stratification per gene | v0.3.12 |
| SV calling | Manta, --exome, call regions = ≥20× | 1.6.0 |
| SV benchmarking | Truvari bench, --pctseq 0, --sizemin 50 | 5.5.0 |
| CNV calling | CNVkit batch, flat reference, CBS segmentation | conda (record version) |
| Workflow | Snakemake | 9.27.0 |

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

### 5.3 Exons below 20× (per-exon analysis)

| Gene | Exon (MANE) | Region (GRCh38) | bp | Mean depth | Min depth | % ≥20× | GC% |
|---|---|---|---|---|---|---|---|
| RORA | exon 1 | chr15:61229043-61229228 | 186 | 12 | 5 | 0.0% | 71% |
| CRY1 | exon 1 | chr12:107092794-107092971 | 178 | 21 | 14 | 48.9% | 66% |
| DBP | exon 1 | chr19:48636846-48637004 | 159 | 31 | 13 | 71.1% | 72% |
| HCRT | exon 2 | chr17:42184147-42184538 | 392 | 96 | 22* | 93.4% | 74% |

*samtools depth counts overlapping read mates twice; mosdepth counts them once, so mosdepth's % ≥20× can be below 100% even when samtools' minimum is ≥20.

Each gene's coverage gap comes entirely from one GC-rich exon (66–74% GC). Three of the four are the first coding exon, a known weak spot of hybrid-capture exomes. The bases below 20× in these exons account exactly for each gene's shortfall in 5.2 (e.g. RORA: 186 of 1,789 bp = 10.4% → 89.6% ≥20×).
Diagnostic consequence: these four exons would need gap-filling (e.g. PCR + Sanger) or a capture design with extra probes before a clock/sleep panel could be reported as complete.

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

## 7. Structural variants (≥50 bp): Manta on exome data

### 7.1 Setup
Manta 1.6.0 in exome mode, restricted to ≥20× regions. PASS calls were compared with GIAB HG002 v5.0q (stvar) using Truvari 5.5.0 (`--pctseq 0 --sizemin 50`). Evaluation region: v5.0q benchmark regions ∩ ≥20× regions = 90.9 Mb.

### 7.2 Overall performance

| Metric | Value |
|---|---|
| Manta PASS calls | 125 (80 DEL, 13 DUP, 14 INS, 18 BND) |
| Truth SVs in evaluation region | 403 |
| TP / FN / FP | 25 / 378 / 28 |
| Recall | 6.2% |
| Precision | 47.2% |
| F1 | 11.0% |

### 7.3 Recall by type and size

| Type | Size | TP | FN | Recall |
|---|---|---|---|---|
| DEL | 50–99 bp | 10 | 34 | 23% |
| DEL | 100–299 bp | 1 | 13 | 7% |
| DEL | 300 bp–10 kb | 2 | 1 | 67% |
| **DEL total** | | **13** | **48** | **21%** |
| INS | 50–99 bp | 10 | 64 | 14% |
| INS | 100–299 bp | 2 | 100 | 2% |
| INS | ≥300 bp | 0 | 166 | 0% |
| **INS total** | | **12** | **330** | **3.5%** |

Interpretation: insertions are 85% of truth SVs in exome-covered regions, and short-read exome data detects almost none of them. No insertion ≥300 bp was found; many of these are probably mobile-element insertions such as Alu elements. Breakpoints of most SVs lie in introns or flanks that the capture does not cover.

## 8. Copy-number variants: single-sample exome CNV calling

### 8.1 Test set
HG002 carries 25 truth deletions ≥10 kb that overlap MANE coding exons (v5.0q benchmark regions). Most are known common deletion polymorphisms, for example GSTM1, LCE3B/C, CFHR3–CFHR1, UGT2B17, GSTT2B, PGA3/4 and PSG4/9. All are heterozygous (GT 0|1 or 1|0); at CR1, SPDYE and SIRPB1 the two haplotypes carry different deletion alleles.

### 8.2 Runs

| Run | Targets | Reference | Bin noise (MAD / biweight midvariance) | Autosomal loss segments | Truth deletions found |
|---|---|---|---|---|---|
| r1 | MANE CDS ±10 bp, low-coverage bins dropped | flat, female | not recorded | 113 (incl. X/Y; 104 cn=0) | 5/25* |
| r2 | MANE CDS ±10 bp, all bins kept | flat, male | 0.63 / 0.69 | 64 | 1/25 |
| r3 | MANE CDS ∩ ≥20× (34.6 Mb) | flat, male | 0.60 / 0.67 | 54 | 2/25* |

*Hits at r1 were in SPDYE, PGA3/4, GOLGA6L4 and NOMO2 with cn=0; in r3, PCDHA (cn=1, segment much larger than the deletion) and GOLGA6C/D (cn=0). Given heterozygous truth genotypes, cn=0 calls in segmental duplications are artefacts that overlap a real deletion by chance. A looser CBS threshold (10⁻² or 10⁻³) did not recover more deletions in r2.

### 8.3 Why deletions are missed
- Noise: exon-to-exon variation in capture efficiency (MAD ≈ 0.6 log2) is as large as the expected heterozygous signal (log2 −1). Without a reference of same-kit samples, CNVkit cannot normalise this.
- The signal is present in the bins: uniquely mappable loci show mean bin log2 of −0.7 to −1.4, consistent with one copy, at LCE3B/C (−1.06), UGT2B17 (−0.80), PIP/TAS2R39 (−0.74), NPIPB6/7 (−1.37) and KRTAP9-6/7 (−1.28). The segmentation did not separate these short events (4–31 bins) from noise.
- Mappability: at 10 of 25 loci, fewer than 20% of reads have MAPQ ≥20 (CR1, ALG1L2, PCDHA, SPDYE, ZAN, FFAR3/GPR42, PSG4/9, GSTT2B). Read depth there reflects mapping, not copy number.

### 8.4 Statement for the validation file
Single-sample exome CNV calling with a flat reference is not fit for purpose: it recovered 1–2 of 25 known heterozygous exonic deletions ≥10 kb, and most of its loss calls are artefacts. Exome CNV calling requires a pooled reference of same-kit samples (typically ≥10) from the host laboratory. Genome-sequencing read depth, which has more uniform coverage, is preferred.

## 9. Conclusions

1. The final configuration is DeepVariant 1.6.1 (WES model), called on MANE CDS ±100 bp. On MANE coding exons ±10 bp it reached SNP recall 97.6% / precision 99.7% and INDEL recall 92.8% / precision 97.8%.
2. The main limit on small-variant sensitivity is capture coverage (3.2% of coding bases <20×), not the caller.
3. DeepVariant clearly outperforms GATK HaplotypeCaller with hard filters on this data.
4. Clock/sleep panel: all 31 truth SNPs detected with no false positives. Coverage ≥20× is 99.24% overall, with gaps in RORA, HCRT, CRY1 and DBP.
5. Structural variants: exome sequencing with Manta detects 6.2% of SVs ≥50 bp in covered regions (deletions 21%, insertions 3.5%, insertions ≥300 bp 0%).
6. CNVs: a single exome with a flat reference does not reliably detect heterozygous exonic deletions (1–2/25).
7. Consequence for the research project: rare structural and copy-number variation in clock genes cannot be assessed with single exomes. The project will use genome sequencing for SV/CNV analysis, with long-read sequencing for unresolved candidate cases, and a pooled reference cohort for any exome CNV calling.

## 10. Open items

- Report low-coverage calls (<20×) separately as "requires confirmation".
- Stratify with GIAB GRCh38 stratifications (GC content, low-complexity regions, segmental duplications).
- Coverage titration (downsampling to 50% / 25%).
- Optional: GATK with BQSR and separate SNP/indel filters, called on CDS ±100 bp.
- Optional: exome CNV with a pooled reference (e.g. ExomeDepth with HG003/HG004 and further same-kit exomes).
- Add the SV and CNV steps to the Snakemake workflow.
