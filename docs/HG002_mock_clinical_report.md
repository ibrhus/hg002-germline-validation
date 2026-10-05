# MOCK CLINICAL REPORT – FOR TRAINING ONLY, NOT FOR CLINICAL USE

## Molecular Genetic Report: Circadian Rhythm Sleep Disorder Panel

| | |
|---|---|
| Patient | "Mock patient" (GIAB reference sample HG002 / NA24385), male |
| Date of birth | – (reference sample) |
| Sample | Genomic DNA (NIST RM 8391) |
| Referring physician | – (training case) |
| Indication | Suspected familial advanced sleep phase disorder (FASPD): habitual sleep onset ~19:00, wake ~04:00, positive family history (fictitious) |
| Test | Exome sequencing with virtual panel analysis (29 genes) |
| Report date | 5 October 2026 |

### Result

**No pathogenic or likely pathogenic variant was detected in the analysed genes that could explain the reported phenotype.**

### Genes analysed

Core clock: CLOCK, BMAL1, BMAL2, NPAS2, PER1, PER2, PER3, CRY1, CRY2, NR1D1, NR1D2, RORA, RORB, RORC, CSNK1D, CSNK1E, FBXL3, TIMELESS, DBP, NFIL3, TEF
Sleep traits/disorders: BHLHE40, BHLHE41, ADRB1, NPSR1, GRM1, HCRT, HCRTR2
Other: GAPVD1

Primary FASPD genes for this indication: PER2, CSNK1D, CRY2, PER3, TIMELESS.

### Variants of uncertain significance

None reported for this indication.

The BHLHE41 variant NM_030762.3:c.1215_1223dup p.(Ala409_Ala411dup), heterozygous, was classified internally as a VUS (PM2_Supporting, BP3). It is not reported because:
1. BHLHE41 is associated with familial natural short sleep, not with FASPD.
2. It is an in-frame duplication within a polyalanine repeat.
3. Read support was low (VAF 0.23).

Benign and likely benign variants are not reported, in line with ACMG recommendations. A full list is held by the laboratory.

### Methods

- **Sequencing:** exome enrichment (Agilent SureSelect Human All Exon v5), Illumina paired-end sequencing, 75.2 million read pairs.
- **Bioinformatics:**
  - Alignment: BWA-MEM 0.7.19 to GRCh38
  - Duplicate marking: samtools 1.24
  - Variant calling: DeepVariant 1.6.1 (WES model) on MANE Select coding exons ±100 bp
  - Annotation: Ensembl VEP (gnomAD v4, ClinVar, CADD, REVEL, AlphaMissense, SpliceAI)
- **Classification:** ACMG/AMP 2015 with ClinGen SVI recommendations.
- **Nomenclature:** HGVS on MANE Select transcripts.
- **Validation:** benchmarked against GIAB HG002 v4.2.1 on MANE Select CDS ±10 bp: SNV sensitivity 97.6%, precision 99.7%; indel sensitivity 92.8%, precision 97.8%.

### Coverage and limitations

- Mean depth across the panel's coding regions: 182×. 99.24% of target bases were covered at ≥20×.
- **The following regions were not adequately covered (<20×) and were therefore not fully assessable:**

| Gene | Region | Coverage ≥20× |
|---|---|---|
| RORA | exon 1 (MANE), chr15:61229043-61229228 | 0% |
| CRY1 | exon 1 (MANE), chr12:107092794-107092971 | 49% |
| DBP | exon 1 (MANE), chr19:48636846-48637004 | 71% |
| HCRT | exon 2 (MANE), chr17:42184147-42184538 | 93% |

- Not detected or not reliably detected by this method:
  - copy-number variants and structural variants (not analysed)
  - deep intronic and regulatory variants
  - repeat expansions
  - mosaicism below ~20% allele fraction
  - variants in GC-rich repeat regions (reduced indel sensitivity)
- A negative result does not exclude a genetic cause of the phenotype.

### Interpretation and recommendation

No genetic cause of the suspected advanced sleep phase disorder was identified in the analysed genes. Familial ASPD is genetically heterogeneous, and many families have no variant in known genes. We recommend:

1. Clinical confirmation of the phenotype (sleep diary, actigraphy, dim-light melatonin onset).
2. Gap-filling Sanger sequencing of the regions listed above, if clinically indicated (CRY1 exon 1 is relevant to circadian phenotypes).
3. Re-analysis of the exome data in 1–2 years, or extension to genome sequencing, if the phenotype persists and the family history is strong.
4. Genetic counselling for the patient and family.

---
Analysed by: ______________________ (Bioinformatics)
Reviewed and approved: ______________________ (Fachhumangenetiker/in)

This is a training document generated from public reference data (GIAB HG002). It does not refer to a real patient and must not be used for clinical decisions.
