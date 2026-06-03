### **Determine SNP sites**
#We used bcftools to filter core SNPs and exclude non-tubingensis strains:

# 1. Filter VCF for PASS, 0% missingness, and exclude unwanted samples
bcftools view \
    -i 'FILTER="PASS" && F_MISSING==0' \
    /home/puntm/my_scratch_dir/2026_refbased/all_scaffolds.filteredSNPs.vcf.gz \
    -Oz -o /home/puntm/my_scratch_dir/2026_black_aspergillus/data/ATL_core.vcf.gz

# Note: If you don't want to exclude those samples, just remove the "-S ^..." line completely.

# 2. Next use plink to create table with pairwise comparisons:
INPUT="/home/puntm/my_scratch_dir/2026_black_aspergillus/data/ATL_core.vcf.gz"

plink \
  --allow-extra-chr \
  --vcf "$INPUT" \
  --genome full \
  --out /home/puntm/my_scratch_dir/2026_black_aspergillus/data/ATL.core