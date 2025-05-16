#!/bin/bash

#SBATCH --job-name nextflow
#SBATCH -A naiss2025-22-494
#SBATCH -p shared
#SBATCH -n 1
#SBATCH -c 2
#SBATCH --mem=5GB
#SBATCH -t 08:30:00
#SBATCH --output=slurm-logs/nf-SLURM-%j.out
#SBATCH --error=slurm-logs/nf-SLURM-%j.err
#SBATCH --mail-user=andbou95@gmail.com
#SBATCH --mail-type=ALL

ml load PDC/23.12 
ml load apptainer/1.3.6-cpeGNU-23.12
ml load nextflow/24.04.2



nextflow run main.nf -params-file stam-params.yml
