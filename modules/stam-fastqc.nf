#!/usr/bin/env nextflow

process FASTQC {

    label "qc"
    tag "${meta.sample}_${meta.lane}"

    container params.images.QC

    input:
    tuple val(meta), path(read)

    output:
    path "*_fastqc.html", emit: fastqc_html
    path "*_fastqc.zip"

    script:
    """
    fastqc $read --threads ${task.cpus}
    """
}



