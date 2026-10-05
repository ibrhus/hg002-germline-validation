# HG002 – Clock/Sleep Panel: ACMG/AMP Variant Classification

Pipeline: DeepVariant 1.6.1 (MANE CDS ±100 bp calling), PASS calls in 29-gene panel (MANE Select CDS ±10 bp), plus the BHLHE41 insertion from the ≥20× run.
Annotation: Ensembl VEP REST (GRCh38; gnomAD v4 exomes/genomes, CADD, REVEL, AlphaMissense, SpliceAI, GERP conservation, ClinVar via Ensembl).
Criteria: ACMG/AMP 2015 (Richards et al.), with ClinGen SVI refinements (PM2_Supporting; REVEL calibration from Pejaver et al. 2022; SpliceAI <0.1 for BP7).

Population-frequency rule: BA1 (stand-alone benign) when gnomAD popmax allele frequency is >5%. For the rare autosomal-dominant sleep-phase disorders in this panel, any allele with popmax ≥1% is far above the maximum credible allele frequency, so BS1 applies.

## Summary

| Class | Count |
|---|---|
| Pathogenic | 0 |
| Likely pathogenic | 0 |
| VUS | 1 |
| Likely benign | 3 |
| Benign | 28 |
| Total | 32 |

## Variants that are not stand-alone benign

| Gene | HGVS (MANE Select) | Protein | Zyg. | popmax AF | In silico | Criteria | Class |
|---|---|---|---|---|---|---|---|
| BHLHE41 | NM_030762.3:c.1215_1223dup | p.(Ala409_Ala411dup) | het (VAF 0.23) | 1.5×10⁻⁵ | in-frame dup in polyalanine stretch; GERP −0.36 | PM2_Supporting, BP3 | **VUS** |
| NPAS2 | NM_002518.4:c.1920G>A | p.(Ala640=) | het | 0.027 | SpliceAI max 0.01; GERP 0.46 | BS1, BP7 | Likely benign |
| CSNK1D | NM_001893.6:c.1077C>T | p.(Pro359=) | het | 0.027 | SpliceAI max 0.09; GERP 1.86 | BS1, BP7 | Likely benign |
| CSNK1D | NM_001893.6:c.858C>T | p.(Tyr286=) | het | 0.016 | SpliceAI max 0.01; ClinVar: benign | BS1, BP7 | Likely benign |

Notes

- **BHLHE41 c.1215_1223dup:** this duplicates three alanines in a GCG/GCC repeat. Rule BP3 (in-frame indel in a repetitive region without known function) applies, so PM4 does not. PM2_Supporting plus BP3 gives conflicting evidence, which classifies as a VUS. Caveats:
  - The gnomAD frequency in repeat regions is unreliable, because of alignment and normalisation differences.
  - The call is low-confidence (6/26 alt reads, GQ 26) and needs orthogonal confirmation.
  - BHLHE41 is linked to familial natural short sleep, a trait rather than a disease. Clinical validity for diagnostic reporting is limited.
- **CSNK1D:** this is the FASPS gene (autosomal dominant). Frequencies of 1.6–2.7% rule out a causal role for a rare dominant disorder.
- **Likely benign, not benign:** with BS1 (strong) + BP7 (supporting), the ACMG combining rules give Likely benign.

## Benign variants (BA1, popmax >5%)

| Gene | HGVS | Protein | popmax AF |
|---|---|---|---|
| PER3 | NM_001377275.1:c.1338T>C | p.(Ser446=) | 0.968 |
| PER3 | NM_001377275.1:c.2504T>C | p.(Leu835Pro) | 1.0* |
| PER3 | NM_001377275.1:c.3057A>G | p.(Thr1019=) | 0.573 |
| NPAS2 | NM_002518.4:c.1055+5C>T | – | 0.475 |
| NPAS2 | NM_002518.4:c.1180A>G | p.(Thr394Ala) | 0.906 |
| PER2 | NM_022817.3:c.1995G>A | p.(Ser665=) | 0.126 |
| CLOCK | NM_004898.4:c.1764T>C | p.(Asn588=) | 0.813 |
| HCRTR2 | NM_001384272.1:c.922A>G | p.(Ile308Val) | 0.947 |
| GRM1 | NM_001278064.2:c.2793G>A | p.(Lys931=) | 0.601 |
| GRM1 | NM_001278064.2:c.2977T>C | p.(Ser993Pro) | 0.707 |
| GRM1 | NM_001278064.2:c.3168T>G | p.(Gly1056=) | 0.902 |
| GRM1 | NM_001278064.2:c.3495C>A | p.(Pro1165=) | 0.676 |
| NPSR1 | NM_207172.2:c.320A>T | p.(Asn107Ile) | 0.545 |
| RORB | NM_006914.4:c.252G>A | p.(Arg84=) | 0.178 |
| GAPVD1 | NM_001282680.3:c.1518T>C | p.(Ile506=) | 1.0* |
| CRY2 | NM_021117.5:c.216-4A>G | – | 0.942 |
| BHLHE41 | NM_030762.3:c.893C>T | p.(Ala298Val) | 0.600 |
| TIMELESS | NM_003920.5:c.3053C>T | p.(Pro1018Leu) | 0.570 |
| TIMELESS | NM_003920.5:c.2492G>A | p.(Arg831Gln) | 0.727 |
| TIMELESS | NM_003920.5:c.1363A>T | p.(Ile455Leu) | 0.733 |
| TIMELESS | NM_003920.5:c.765G>A | p.(Val255=) | 0.727 |
| TIMELESS | NM_003920.5:c.114G>C | p.(Leu38=) | 0.643 |
| CRY1 | NM_004075.5:c.636T>C | p.(Gly212=) | 0.968 |
| FBXL3 | NM_012158.4:c.472-10T>G | – | 0.673 |
| RORA | NM_134261.3:c.1428C>A | p.(Thr476=) | 1.0* |
| PER1 | NM_002616.3:c.2884G>C | p.(Ala962Pro) | 0.908 |
| PER1 | NM_002616.3:c.2361A>G | p.(Thr787=) | 0.853 |
| PER1 | NM_002616.3:c.2247C>T | p.(Gly749=) | 0.854 |

*AF ≈ 1.0: the GRCh38 reference carries the rare allele at this position, so almost everyone (including HG002) carries the "alternative" allele.

## Learning points

- 28/32 variants (88%) are resolved by allele frequency alone. Most of real diagnostic interpretation is efficient exclusion of common variation.
- Missense variants with high frequency (e.g. PER3 p.Leu835Pro, NPSR1 p.Asn107Ile) are benign regardless of in-silico scores.
- Repeat-region indels need BP3/PM4 judgement, and their population frequencies should be treated with caution.
- Gene–disease validity (ClinGen) matters as much as variant evidence. Trait genes (e.g. BHLHE41 short sleep) are usually not reported in a diagnostic panel.
