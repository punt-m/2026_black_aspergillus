##  Overview
- This repo is contains the scripts used in the black aspergillus paper (DOI:XX)
- For R, part of the packages required must be installed separatly 
- Most required data is supplied via the /data folder here, sequencing data can be downloaded fron NCBI (PRJNA:XXX), a dummy data set is supplied in /data

## Scripts
- Scripts to build MIC overview or the specimen table are listed in /scripts/Rscripts/

##  UFCG 
- Genome assemblies are not provided, but an example for the meta_info.tsv and the final tree are kept in the /data folder. With UFCG.sh script and a set of genome assemblies the tree can be rebuild.


## Download data from NCBI (PRJNA1253755) 
  Wang. Triazole Resistance and Misidentification of Aspergillus tubingensis in Southern
  California. JAMA Netw Open. Published December 05, 2025.
  doi:10.1001/jamanetworkopen.2025.43630

<pre>
while read srr; esearch -db sra -query "PRJNA1253755" | efetch -format runinfo | awk -F',' '$29 == "Aspergillus tubingensis" {print $1}' > tubingensis_srrs.txt
</pre>
