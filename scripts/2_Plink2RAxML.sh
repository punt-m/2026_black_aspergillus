#!/bin/bash
OUTNAME="atubingensis"
THREADS=22

mkdir -p output

#prune variants:
plink \
  --allow-extra-chr \
  --make-bed \
  --set-missing-var-ids @:# \
  --out output/$OUTNAME \
  --indep-pairwise 50 10 0.1 \
  --geno 0.1 \
  --maf 0.01 \
  --snps-only just-acgt \
  --vcf ../all_scaffolds.filteredSNPs.vcf.gz \
  --vcf-half-call missing

#recode the : to tab
sed 's/:/\t/g' output/$OUTNAME.prune.in > output/targets.txt

#use pruned locations to prune VCF file
bcftools view -T output/targets.txt ../all_scaffolds.filteredSNPs.vcf.gz --output pruned.vcf.gz

#convert to phylip format
vcf2phylip.py --input pruned.vcf.gz

#run raxml (submit separately as job on cluster ):
raxml-ng --msa pruned.min4.phy \
    --model GTR+G+ASC_LEWIS \
    --all \
    --bs-trees autoMRE \
    --threads $THREADS
