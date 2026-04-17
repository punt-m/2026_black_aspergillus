### **Determine SNP sites**
#We used bcftools to filter core SNPs and exclude non-tubingensis strains:

bcftools view -S ^no_atubingensis.list \
    -f PASS \
    -i 'F_MISSING == 0' \
    ../all_scaffolds.filteredSNPs.vcf.gz \
    -Oz -o atubingensis_core_sensu_stricto.vcf.gz

#  Next use plink to create table with pairwise comparisons:
  INPUT="atubingensis_core_sensu_stricto.vcf.gz"
plink \
  --allow-extra-chr \
  --vcf $INPUT \
  --genome full \
  --out output/atub_197iso
