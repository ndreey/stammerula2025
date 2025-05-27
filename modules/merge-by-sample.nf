#!/usr/bin/env nextflow

process mergeBySample {

    label 'stats'
    tag "mergeBySample-${sample_id}"

    publishDir "${params.res.mergedSample}", mode: 'symlink', 
    pattern: '*_R{1,2}.fq.gz'

    container params.images.QC

    input:
    tuple val(sample_id), val(pop), path(r1_files), path(r2_files)

    output:
    tuple val(sample_id), val(pop), 
    path("${pop}_${sample_id}_R1.fq.gz"),
    path("${pop}_${sample_id}_R2.fq.gz"), 
    emit: sample_merged

    script:
    """
    R1_OUT=${pop}_${sample_id}_R1.fq.gz
    R2_OUT=${pop}_${sample_id}_R2.fq.gz

    echo "[INFO] Merging R1 files for sample ${sample_id}"
    echo "R1 files: ${r1_files}"

    # Merge all R1 files for this sample
    zcat ${r1_files} | pigz -p ${task.cpus} > \$R1_OUT

    
    echo "[INFO] Merging R2 files for sample ${sample_id}"  
    echo "R2 files: ${r2_files}"

    # Merge all R2 files for this sample
    # Multiple files  
    zcat ${r2_files} | pigz -p ${task.cpus} > \$R2_OUT
    """
}