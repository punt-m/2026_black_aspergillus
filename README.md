

##  Overview
- This repo is contains the scripts used in the black aspergillus paper (DOI:XX)
- For R, part of the packages required must be installed separatly 
- Most required data is supplied via the <code>/data</code> folder here, sequencing data can be downloaded fron NCBI (PRJNA:XXX), a dummy data set is supplied in <code>/data</code>

## Scripts
- Scripts to build MIC overview or the specimen table are listed in <code>/scripts/Rscripts/</code>

##  UFCG 
- Genome assemblies are not provided, but an example for the <code>meta_info.tsv</code> and the final tree are kept in the <code>/data</code> folder. With <code>UFCG.sh</code> script and a set of genome assemblies the tree can be rebuild.

## Determine SNP sites
We used bcftools to count total variants:
<pre>
bcftools query -i 'MAC>=1 && MAF>0' -f '%CHROM\n' all_scaffolds.filteredSNPs.vcf.gz | wc -l
bcftools view -f PASS -Oz -o high_qual.snps.vcf.gz all_scaffolds.filteredSNPs.vcf.gz
bcftools view -i 'F_MISSING == 0' high_qual.snps.vcf.gz -Oz -o no_missing_HQ.vcf.gz
bcftools view no_missing_HQ.vcf.gz | wc -l === 2115268 
</pre>


## Download data from NCBI (PRJNA1253755) 

 Data from:
  Wang. Triazole Resistance and Misidentification of Aspergillus tubingensis in Southern
  California. JAMA Netw Open. Published December 05, 2025.
  doi:10.1001/jamanetworkopen.2025.43630

<pre>
while read srr; esearch -db sra -query "PRJNA1253755" | efetch -format runinfo | awk -F',' '$29 == "Aspergillus tubingensis" {print $1}' > tubingensis_srrs.txt
</pre>
