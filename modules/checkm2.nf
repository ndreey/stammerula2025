#!/usr/bin/env nextflow

process CHECKM2 {

    label "checkm2"
    tag "checkm2-${pop}"

    publishDir "${params.res.binQuality}/${pop}/checkm2", mode: 'symlink'

    container params.images.checkm2

    input:
    tuple val(pop), path(refined_bins_dir)

    output:
    tuple val(pop), path("checkm2_output"), emit: checkm2_results

    script:
    """
    echo "[INFO] Running CheckM2 predict on refined bins"
    checkm2 predict \\
        --threads ${task.cpus} \\
        --input ${refined_bins_dir}/metawrap_50_10_bins \\
        --output-directory checkm2_output \\
        --allmodels \\
        --extension ".fa" \\
        --database_path /checkm2_db \\
        --force

    echo "[INFO] CheckM2 analysis completed for \$(ls ${refined_bins_dir}/metawrap_50_10_bins/*.fa | wc -l) bins"
    """
}
