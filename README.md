# HG002 germline exome validation pipeline

Reproducible Snakemake workflow that aligns a GIAB HG002 exome, calls small variants with DeepVariant (and optionally GATK HaplotypeCaller), and benchmarks them against the GIAB v4.2.1 truth set on MANE Select coding exons. It reports per-gene and per-exon coverage for a 29-gene circadian clock / sleep panel, benchmarks structural variants (Manta vs GIAB v5.0q, Truvari) and tests single-sample exome CNV calling (CNVkit). Panel variants are annotated with Ensembl VEP and classified by ACMG/AMP criteria.

This is preliminary work for a research project on rare coding and structural variants in core clock genes in circadian rhythm sleep–wake disorders.

## Results (HG002, Agilent SureSelect v5, GRCh38)

Evaluated on MANE Select CDS ±10 bp ∩ GIAB high-confidence regions (chr1–22):

| Caller | Type | Recall | Precision |
|---|---|---|---|
| DeepVariant 1.6.1 (CDS ±100 bp calling) | SNP | 97.64% | 99.72% |
| DeepVariant 1.6.1 (CDS ±100 bp calling) | INDEL | 92.76% | 97.76% |
| GATK HC 4.6.2, hard filters (≥20× calling) | SNP | 95.08% | 98.14% |
| GATK HC 4.6.2, hard filters (≥20× calling) | INDEL | 84.32% | 88.47% |

- 96.8% of MANE CDS ±10 bp bases are covered ≥20×; 80% of the false negatives fall in regions below 20×.
- Clock/sleep panel: 31/31 truth SNPs detected, 0 false positives; 99.24% of panel bases ≥20×.
- Known limitation: a 9-bp in-frame insertion in a GCG repeat in BHLHE41 (chr12:26122291) is detected unreliably (VAF 0.23, 6/26 reads).

### Structural variants and CNVs (report v3)

| Analysis | Result |
|---|---|
| Manta (exome) vs GIAB v5.0q, SVs ≥50 bp, 90.9 Mb | Recall 6.2%, precision 47.2% (403 truth SVs) |
| Deletions / insertions | Recall 21% / 3.5%; insertions ≥300 bp: 0/166 |
| CNVkit, single sample, flat reference | 1–2 of 25 known heterozygous exonic deletions ≥10 kb |

Consequence: single exomes cannot assess structural or copy-number variation in clock genes; genome sequencing (and long reads for unresolved cases) is required.

### Interpretation
- `scripts/vep_panel.py`: annotation of panel variants via the Ensembl VEP REST API (gnomAD, CADD, REVEL, AlphaMissense, SpliceAI, ClinVar).
- 32 panel variants classified: 28 benign, 3 likely benign, 1 VUS (BHLHE41 in-frame duplication). See `docs/HG002_panel_ACMG_classification.md` and the training report `docs/HG002_mock_clinical_report.md` (not for clinical use).

Full details: `docs/HG002_validation_report_v3.md` (v1 and v2 kept for reference).

## Workflow

```
GIAB BAM → FASTQ → bwa mem → fixmate/sort/markdup → mosdepth
                                            ↓
GENCODE v49 MANE Select → CDS ±10 bp (evaluation) / ±100 bp (calling) / panel BEDs
                                            ↓
              DeepVariant (WES) [ + GATK HaplotypeCaller, optional ]
                                            ↓
     hap.py vs GIAB v4.2.1 (-T CDS, per-gene stratification) → summary, per-gene table
     panel gene coverage, per-exon coverage of low-coverage genes
```

## Requirements

- Linux, ≥16 cores, ≥32 GB RAM (bwa index ~5 GB), ~60 GB free disk
- Docker (DeepVariant, hap.py)
- Conda/mamba: `conda env create -f envs/ngs.yaml && conda activate ngs`

## Usage

1. Edit `config/config.yaml` (`workdir`, `threads`).
2. Dry run: `snakemake -s workflow/Snakefile -n`
3. Run: `snakemake -s workflow/Snakefile --cores 24`
4. Optional GATK comparison: `snakemake -s workflow/Snakefile --cores 24 gatk_all`

If outputs already exist from a manual run, add `--rerun-triggers mtime` so that only missing results are produced.

## Outputs

| File | Content |
|---|---|
| `qc/HG002.flagstat.txt` | Alignment QC |
| `qc/HG002.cds_coverage.txt` | Fraction of MANE CDS ≥20× |
| `happy_v2/HG002.deepvariant_cds100.summary.csv` | Recall/precision on MANE CDS |
| `happy_v2/HG002.deepvariant_cds100.per_gene.txt` | Per-gene recall for the panel |
| `qc/panel_gene_coverage.tsv` | Per-gene coverage (mean, % ≥10/20/30×) |
| `qc/exons/exon_coverage.tsv` | Per-exon coverage and GC% for selected genes |
| `versions.txt` | Tool versions |
| `sv/truvari_manta/summary.json` | SV benchmark (`scripts/sv_cnv.sh`) |
| `cnv/r3/HG002.call.cns` | CNVkit segments and copy-number calls |

## Gene panel

Core clock: CLOCK, BMAL1, BMAL2, NPAS2, PER1–3, CRY1/2, NR1D1/2, RORA/B/C, CSNK1D/E, FBXL3, TIMELESS, DBP, NFIL3, TEF
Sleep traits and disorders: BHLHE40, BHLHE41, ADRB1, NPSR1, GRM1, HCRT, HCRTR2
Other: GAPVD1

## Data sources

- GIAB HG002 exome and truth set: https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/
- GRCh38 no-alt analysis set (GIAB)
- GENCODE v49: https://www.gencodegenes.org/

## License

MIT
