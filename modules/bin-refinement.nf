#!/usr/bin/env nextflow

process binRefinement {

    label "metaWRAP"
    tag "binRefinement-${pop}"

    publishDir "${params.res.binRef}/${pop}", mode: 'symlink'

    container params.images.metaWRAP

    input:
    tuple val(pop), path(concoct_bins), path(maxbin2_bins), path(metabat2_bins)

    output:
    tuple val(pop), path("bin_refinement"), emit: refined_bins

    script:
    """
    metawrap bin_refinement \\
        -o bin_refinement \\
        -t ${task.cpus} \\
        -m 64 \\
        -A ${concoct_bins} \\
        -B ${maxbin2_bins} \\
        -C ${metabat2_bins} \\
        -c 50 \\
        -x 10
    """
}




