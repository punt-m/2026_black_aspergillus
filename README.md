

##  Overview
- This repo is contains the scripts used in the black aspergillus paper (DOI:XX)
- For R, part of the packages required must be installed separatly 
- Most required data is supplied via the <code>/data</code> folder here, sequencing data can be downloaded fron NCBI (PRJNA:XXX), a dummy data set is supplied in <code>/data</code>

## Scripts
- Scripts to build MIC overview or the specimen table are listed in <code>/scripts/Rscripts/</code>

##  UFCG 
- Genome assemblies are not provided, but an example for the <code>meta_info.tsv</code> and the final tree are kept in the <code>/data</code> folder. With <code>UFCG.sh</code> script and a set of genome assemblies the tree can be rebuild.

## Determine SNP sites
We used bcftools to filter core SNPs and exclude non-tubingensis strains:
<pre>
bcftools view -S ^no_atubingensis.list \
    -f PASS \
    -i 'F_MISSING == 0' \
    ../all_scaffolds.filteredSNPs.vcf.gz \
    -Oz -o atubingensis_core_sensu_stricto.vcf.gz
</pre>
Next use plink to create table with pairwise comparisons:
<pre>
INPUT="atubingensis_core_sensu_stricto.vcf.gz"

plink \
  --allow-extra-chr \
   --vcf $INPUT \
   --genome full \
   --out output/atub_197iso
</pre>

## Download data from NCBI (PRJNA1253755) 

 Data from:
  Wang. Triazole Resistance and Misidentification of Aspergillus tubingensis in Southern
  California. JAMA Netw Open. Published December 05, 2025.
  doi:10.1001/jamanetworkopen.2025.43630

<pre>
while read srr; esearch -db sra -query "PRJNA1253755" | efetch -format runinfo | awk -F',' '$29 == "Aspergillus tubingensis" {print $1}' > tubingensis_srrs.txt
</pre>
