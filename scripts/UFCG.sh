#!/bin/bash
#if not done, make sure the input meta is being created in advance. 
#When running both after each other:

#Profiling on LSF-cluster
bsub -e profile_%J.err -o profile_%J.log -n 8 -W 300 -J UCFG_profile \
    singularity run -B /home/puntm/my_scratch_dir/UCFG/:/UCFG ufcg_latest.sif ufcg profile \
    -i /UCFG/genome_assemblies/ \
    -f \
    -o /UCFG/profiles/ -t 8 -v \
    -m /data/meta_info_UFCG.tsv

#Creating tree with FastTree to determine species identity
bsub -e tree_%J.err -o tree_%J.log -n 8 -W 1200 -M 32000 -R "rusage[mem=32000]" -J UCFG_fasttree -w "done(UCFG_profile)" \
    singularity run -B /home/puntm/my_scratch_dir/UCFG/:/UCFG \
                    -B /mnt/scratch_dir/puntm/conda/envs/samtools/bin:/tools ufcg_latest.sif ufcg tree\
    -i /UCFG/profiles/ \
    -v \
    --fasttree /tools/fasttree \
    -p fasttree \
    -o /UCFG/2026_aspergillus \
    -t 8 \
    -l label,strain