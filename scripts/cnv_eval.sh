CNS=$1; N=~/miniconda3/envs/ngs/bin; L=${CNS%.cns}.losses.bed
awk -F'\t' 'NR==1{for(i=1;i<=NF;i++){if($i=="cn")c=i; if($i=="log2")l=i; if($i=="probes")p=i}; next}
  $c<2 && $1!="chrX" && $1!="chrY" {print $1"\t"$2"\t"$3"\t"$c"\t"$l"\t"$p}' $CNS > $L
echo "Autosomal loss segments: $(wc -l < $L) (cn0: $(awk '$4==0' $L|wc -l), cn1: $(awk '$4==1' $L|wc -l), >=3 probes: $(awk '$6>=3' $L|wc -l))"
$N/bedtools intersect -a cnv/truth_dels10k.bed -b $L -wao | \
  awk '{k=$1":"$2"-"$3" "int($4/1000)"kb"; if($5!="."){h[k]="FOUND cn="$8" probes="$10} else if(!(k in h)) h[k]="missed"} END{for(k in h) print k, h[k]}' | sort -V | tee ${CNS%.cns}.truth_eval.txt
echo "Truth found: $(grep -c FOUND ${CNS%.cns}.truth_eval.txt) / $(wc -l < cnv/truth_dels10k.bed)"
echo "Loss segments overlapping truth: $($N/bedtools intersect -u -a $L -b cnv/truth_dels10k.bed | wc -l) / $(wc -l < $L)"
