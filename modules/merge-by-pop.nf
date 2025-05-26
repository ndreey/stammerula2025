#!/usr/bin/env nextflow

process mergeByPop {

    label 'stats'
    tag "mergeByPop-${pop_id}"

    publishDir "${params.res.mergedPop}", mode: 'symlink', pattern: '*_R{1,2}.fq.gz'

    container params.images.QC

    input:
    tuple val(pop_id), path(r1_files), path(r2_files)

    output:
    tuple val(pop_id), path("${pop_id}_R1.fq.gz"), path("${pop_id}_R2.fq.gz"), emit: pop_merged

    script:
    """
    R1_OUT=${pop_id}_R1.fq.gz
    R2_OUT=${pop_id}_R2.fq.gz

    echo "[INFO] Merging R1 files for population ${pop_id}"
    echo "R1 files: ${r1_files}"

    # Merge all R1 files for this population
    zcat ${r1_files} | pigz -p ${task.cpus} > \$R1_OUT

    echo "[INFO] Merging R2 files for population ${pop_id}"  
    echo "R2 files: ${r2_files}"

    # Merge all R2 files for this population
    zcat ${r2_files} | pigz -p ${task.cpus} > \$R2_OUT
    """
}