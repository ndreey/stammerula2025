#!/usr/bin/env nextflow

process GTDBTK {

    label "gtdbtk"
    tag "gtdbtk-${pop}"

    publishDir "${params.res.binQuality}/${pop}/GTDB-Tk", mode: 'symlink'

    container params.images.GTDBTk

    input:
    tuple val(pop), path(refined_bins_dir)

    output:
    tuple val(pop), path("gtdbtk_output"), emit: gtdbtk_results

    script:
    """
    # Set GTDBTK database path
    export GTDBTK_DATA_PATH=/gtdbtk_db

    echo "[INFO] Running GTDB-Tk classify_wf on refined bins"
    gtdbtk classify_wf \\
        --genome_dir ${refined_bins_dir}/metawrap_50_10_bins \\
        --out_dir gtdbtk_output \\
        --cpus ${task.cpus} \\
        --extension "fa" \\
        --mash_db gtdbtk_mash_db/gtdb_ref_sketch.msh

    echo "[INFO] GTDB-Tk classification completed for \$(ls ${refined_bins_dir}/metawrap_50_10_bins/*.fa | wc -l) bins"
    """
}
