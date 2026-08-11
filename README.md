# Evidence for environmental azole resistance selection in _Aspergillus_ series _Nigri_

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

_Authors_: Maarten Punt <a href="https://orcid.org/0000-0001-6053-9073" target="orcid.widget" rel="noopener noreferrer" style="vertical-align:top;"><img src="https://orcid.org/sites/default/files/images/orcid_16x16.png" style="width:1em;margin-right:.5em;" alt="ORCID iD icon"></a><br>
_Contact_: maarten.punt@rivm.nl<br>
_Date_: 10-Apr-2026<br>

This code accompanies the manuscript 'Evidence for environmental azole resistance selection in _Aspergillus_ series _Nigri_'. DOI:XXX

## Description
This repository contains the bash scripts and Rmd-scripts ([`scripts/`](scripts/)) and functions ([`src/`](src/)) that use files from ([`data/`](data/)) to generate results ([`results/`](results/)). 
The R-code  was ran in R (v4.5.0). 

Some of the markdown scripts require input that is generated with bash scripts and the following programs: [bcftools](https://github.com/samtools/bcftools), [plink](https://www.cog-genomics.org/plink2/),[UFCG](https://github.com/steineggerlab/ufcg) and [SnpEff](https://github.com/pcingola/SnpEff.git). They must be installed separately.

### Data Generation
The below scripts were used to generate a phylogenetic trees and mutations profiles from the sequence data. The multi-sample VCF file for the _A. tubingensis_ isolates can be generated as described in the manuscript with [GATK](https://gatk.broadinstitute.org/hc/en-us).

 - [`1_UFCG.sh`](scripts/1_UFCG.sh): LSF bash script build a phylogeny using whole genome assemblies (.fasta). Genome assemblies are not included, but the tree can be found here:[`UFCG_tree.nwk`](data/tree_data/UFCG_tree.nwk). 
 - [`2_Plink2RAxML.sh`](scripts/2_Plink2RAxML.sh): Bash script that prunes a VCF file for linkage disequilibrium using PLINK and generates a maximum likelihood phylogenetic tree via RAxML-NG. Output found here: [`asptu.raxml.tree`](data/tree_data/asptu.raxml.tree). 
 - [`3_extract_AA.py`](scripts/3_extract_AA.py): Use VCF data to identify unique missense mutation profiles per sample for a specific gene and assigning them variant labels (like WT, v1, v2). 
 - [`4_SNP_sites.sh`](scripts/4_SNP_sites.sh): Filter VCF data for core SNPs and use PLINK to calculate a pairwise identity-by-descent (IBD) genomic relationship matrix.


### Visualization scripts
The markdown scripts to generate the figures presented in the article and the supplementary data

 - [`1_MIC_distributions.Rmd`](scripts/Rscripts/1_MIC_distributions.Rmd): Used to generate the MIC distribution overviews.
 - [`2_Phylogenetic_tree.Rmd`](scripts/Rscripts/2_Phylogenetic_tree.Rmd): Visualizes the phylogenetic tree generated with the UFCG data. 
 - [`3_SNP_based_phylogenetic_tree.Rmd`](scripts/Rscripts/3_SNP_based_phylogenetic_tree.Rmd): Build a SNP-based phylogenetic tree, annotated with MIC data and Cyp51 variant info.
 - [`4_clonal_group_analysis.Rmd`](scripts/Rscripts/4_clonal_group_analysis.Rmd): Identifying clonal groups within the _A. tubingensis_ isolates using the PLINK data.
 - [`5_cyp51.Rmd`](scripts/Rscripts/5_cyp51.Rmd): extracts the cyp51 mutations found across all variants provided in the variant call file (.vcf.gz).
 - [`6_GWAS.Rmd`](scripts/Rscripts/6_GWAS.Rmd): reads plink output to generate whole-genome manhattan plots and focus plots for the cyp51a/b genes. Also includes Fst 
 - [`7_group_analysis.Rmd`](scripts/Rscripts/7_group_analysis.Rmd): Generates summary tables of the R/S split between specimens and fungal lineages.
 - [`8_mosdepth.Rmd`](scripts/Rscripts/8_mosdepth.Rmd):

The .html-output of all the scripts can be found the [`results`](results/)-folder.



## Download data from NCBI (PRJNA1253755) 

 Data from:
  Wang. Triazole Resistance and Misidentification of Aspergillus tubingensis in Southern
  California. JAMA Netw Open. Published December 05, 2025.
  doi:10.1001/jamanetworkopen.2025.43630

<pre>
while read srr; esearch -db sra -query "PRJNA1253755" | efetch -format runinfo | awk -F',' '$29 == "Aspergillus tubingensis" {print $1}' > tubingensis_srrs.txt
</pre>
