

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

## Cyp51 analysis
Cyp51A BLWE01000008	582526	584493	locus_tag=AtWU_06533
    Insertion site: BLWE01000008  583109
Cyp51B BLWE01000010	91551	93312	locus_tag=AtWU_09124

Here I look at SNPs and INDELs variant types in the regions encoding for cyp51a and cyp51b +1000 bp flanks.

CYP51A:
<pre>
bcftools view -r BLWE01000008:581899-585491 data/seq_data/BLWE01000008_581899_585491.filteredSNPs.vcf.gz > cyp51A_region.vcf
snpEff -hgvs1LetterAa Aspergillus_tubingensis_gca_013340325 cyp51A_region.vcf > cyp51A_annotated.vcf
bgzip cyp51A_annotated.vcf
bcftools index cyp51A_annotated.vcf
bcftools query -i 'ANN ~ "intron_variant" && ANN ~ "insC" && GT="alt"'  -f '[%SAMPLE\t%GT\n]' cyp51A_annotated.vcf.gz
</pre>

CYP51B:
<pre>
bcftools view -r BLWE01000010:90551-94312 data/seq_data/BLWE01000010_90551_94312.filteredSNPs.vcf.gz > cyp51B_region.vcf
snpEff -hgvs1LetterAa Aspergillus_tubingensis_gca_013340325 cyp51B_region.vcf > cyp51B_annotated.vcf
</pre>

Use extract_AA.py to extract the variants. In snpEff database Cyp51A (AtWU_06533) has two additional exons compared to MH781351. To account for this, all substitutions are subtracted by 52 AAs, which results in the same mutations as found in MH781351. 
<pre>    
python3 extract_AA.py cyp51A_annotated.vcf.gz AtWU_06533 52 > cyp51a.mutations
python3 extract_AA.py cyp51B_annotated.vcf.gz AtWU_09124 0 > cyp51b.mutations

</pre>


## Download data from NCBI (PRJNA1253755) 

 Data from:
  Wang. Triazole Resistance and Misidentification of Aspergillus tubingensis in Southern
  California. JAMA Netw Open. Published December 05, 2025.
  doi:10.1001/jamanetworkopen.2025.43630

<pre>
while read srr; esearch -db sra -query "PRJNA1253755" | efetch -format runinfo | awk -F',' '$29 == "Aspergillus tubingensis" {print $1}' > tubingensis_srrs.txt
</pre>
