#!/usr/bin/env nextflow

process mergeBySample {

    label 'stats'
    tag "mergeBySample-${meta.sample}"

    publishDir "${params.res.mergedSample}", mode: 'symlink', pattern: '*_R{1,2}.fq.gz'

    container params.images.QC

    input:
    tuple val(meta), path(read1), path(read2)

    output:
    path("*_R{1,2}.fq.gz"), emit: sample_merged

    script:
    """
    R1_OUT=${meta.pop}_${meta.sample}_R1.fq.gz
    R2_OUT=${meta.pop}_${meta.sample}_R2.fq.gz

    zcat ${meta.sample}*R1*.fq.gz | gzip > \$R1_OUT

    zcat ${meta.sample}*R2*.fq.gz | gzip > \$R2_OUT
    """
}