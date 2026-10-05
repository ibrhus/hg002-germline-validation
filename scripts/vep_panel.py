#!/usr/bin/env python3
"""Annotate a small VCF with the Ensembl VEP REST API (GRCh38) and add ACMG evidence hints.
Usage: bcftools view ... | python3 vep_panel.py > panel_annotated.tsv
No extra packages needed. Raw JSON is saved to vep_raw.json."""
import sys, json, time, urllib.request

URL = ("https://rest.ensembl.org/vep/homo_sapiens/region?mane=1&hgvs=1&canonical=1"
       "&af_gnomade=1&af_gnomadg=1&CADD=1&REVEL=1&SpliceAI=2&AlphaMissense=1"
       "&variant_class=1&numbers=1&pick=1&pick_order=mane_select,canonical")
LOF = {"stop_gained", "frameshift_variant", "splice_acceptor_variant",
       "splice_donor_variant", "start_lost", "stop_lost", "transcript_ablation"}

def post(batch, tries=5):
    data = json.dumps({"variants": batch}).encode()
    req = urllib.request.Request(URL, data=data, headers={
        "Content-Type": "application/json", "Accept": "application/json"})
    for i in range(tries):
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                return json.load(r)
        except Exception as e:
            sys.stderr.write(f"VEP request failed ({e}), retry {i+1}\n"); time.sleep(5 * (i + 1))
    raise SystemExit("VEP REST API not reachable")

# ---- read VCF ----
recs = {}
for line in sys.stdin:
    if line.startswith("#"): continue
    f = line.rstrip("\n").split("\t")
    chrom, pos, ref, alts = f[0], f[1], f[3], f[4].split(",")
    fmt = dict(zip(f[8].split(":"), f[9].split(":"))) if len(f) > 9 else {}
    for alt in alts:
        key = f"{chrom.replace('chr','')} {pos} . {ref} {alt} . . ."
        recs[key] = dict(chrom=chrom, pos=pos, ref=ref, alt=alt, filter=f[6],
                         gt=fmt.get("GT", ""), gq=fmt.get("GQ", ""), dp=fmt.get("DP", ""),
                         vaf=fmt.get("VAF", ""), ad=fmt.get("AD", ""))

keys = list(recs); out = []
for i in range(0, len(keys), 200):
    out += post(keys[i:i+200]); time.sleep(1)
json.dump(out, open("vep_raw.json", "w"), indent=1)

def num(x):
    try: return float(x)
    except (TypeError, ValueError): return None

cols = ["chrom","pos","ref","alt","gt","gq","dp","vaf","gene","consequence","hgvsc","hgvsp",
        "exon","impact","rsid","gnomade_af","gnomadg_af","popmax_af","popmax_pop","clinvar",
        "cadd","revel","alphamissense","spliceai_max","acmg_hints"]
print("\t".join(cols))
for v in out:
    r = recs.get(v.get("input"), {})
    tc = (v.get("transcript_consequences") or [{}])[0]
    nm = tc.get("mane_select")
    hgvsc = tc.get("hgvsc", ""); hgvsp = tc.get("hgvsp", "")
    if nm and ":" in hgvsc: hgvsc = nm + ":" + hgvsc.split(":", 1)[1]
    hgvsp = hgvsp.split(":", 1)[1] if ":" in hgvsp else hgvsp
    # population frequencies and ClinVar from co-located variants (allele-matched)
    alt_allele = tc.get("variant_allele") or v.get("allele_string", "/").split("/")[-1]
    rsid, clin, afe, afg, pmax, ppop = "", "", None, None, 0.0, ""
    for c in v.get("colocated_variants", []):
        if c.get("id", "").startswith("rs"): rsid = c["id"]
        if c.get("clin_sig"): clin = ",".join(c["clin_sig"])
        fr = (c.get("frequencies") or {}).get(alt_allele)
        if fr:
            afe = fr.get("gnomade", afe); afg = fr.get("gnomadg", afg)
            for k, val in fr.items():
                if k.count("_") == 1 and not k.endswith(("remaining", "ami", "asj", "fin", "mid")) and val > pmax:
                    pmax, ppop = val, k
    cons = ",".join(tc.get("consequence_terms", [v.get("most_severe_consequence", "")]))
    revel = num(tc.get("revel")); cadd = num(tc.get("cadd_phred"))
    am = tc.get("alphamissense") or {}
    am_s = f"{am.get('am_class','')}:{am.get('am_pathogenicity','')}" if am else ""
    sp = tc.get("spliceai") or {}
    sp_max = max([num(sp.get(k)) or 0 for k in ("DS_AG","DS_AL","DS_DG","DS_DL")], default=None) if sp else None
    af = max([x for x in (afe, afg, pmax) if x is not None], default=None)
    hints = []
    if af is None or af < 1e-4: hints.append("PM2_Supporting?")
    if af is not None and af > 0.05: hints.append("BA1")
    elif af is not None and af > 0.01: hints.append("BS1?")
    if set(tc.get("consequence_terms", [])) & LOF: hints.append("PVS1?(check LoF mechanism)")
    if revel is not None:
        if revel >= 0.932: hints.append("PP3_Strong")
        elif revel >= 0.773: hints.append("PP3_Moderate")
        elif revel >= 0.644: hints.append("PP3_Supporting")
        elif revel <= 0.016: hints.append("BP4_Strong")
        elif revel <= 0.183: hints.append("BP4_Moderate")
        elif revel <= 0.290: hints.append("BP4_Supporting")
    if sp_max is not None:
        if sp_max >= 0.2: hints.append("PP3(splice)")
        elif sp_max < 0.1 and "synonymous_variant" in cons: hints.append("BP7?")
    if "inframe" in cons: hints.append("PM4?(in-frame; check repeat)")
    row = [r.get("chrom",""), r.get("pos",""), r.get("ref",""), r.get("alt",""), r.get("gt",""),
           r.get("gq",""), r.get("dp",""), r.get("vaf",""), tc.get("gene_symbol",""), cons, hgvsc, hgvsp,
           tc.get("exon",""), tc.get("impact",""), rsid,
           "" if afe is None else f"{afe:.3g}", "" if afg is None else f"{afg:.3g}",
           f"{pmax:.3g}" if ppop else "", ppop, clin,
           "" if cadd is None else f"{cadd:.1f}", "" if revel is None else f"{revel:.3f}",
           am_s, "" if sp_max is None else f"{sp_max:.2f}", ";".join(hints)]
    print("\t".join(map(str, row)))
