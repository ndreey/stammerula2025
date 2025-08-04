#!/bin/bash

#SBATCH --job-name nextflow
#SBATCH -A naiss2025-22-494
#SBATCH -p shared
#SBATCH -n 1
#SBATCH -c 2
#SBATCH --mem=5GB
#SBATCH -t 2-23:00:00
#SBATCH --output=slurm-logs/nf-SLURM-%j.out
#SBATCH --error=slurm-logs/nf-SLURM-%j.err
#SBATCH --mail-user=andbou95@gmail.com
#SBATCH --mail-type=ALL


#ml load PDC/24.11
#ml load apptainer/1.4.0-cpeGNU-24.11
#ml load nextflow/24.04.2
#ml load bioinfo-tools
#ml load Graphviz/9.0.0

# Load in the kraken2 mamba environment
source /cfs/klemming/home/a/andbou/.bashrc
mamba activate nf

nextflow run main.nf -params-file stam-params.yml -profile slurm -resume
