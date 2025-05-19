#!/usr/bin/env nextflow

process FASTQC {

    label "qc"

    tag "${reads.simpleName}"

    container params.images.QC
    
    input:
    path reads

    output:
    path "*_fastqc.html", emit: fastqc_html
    path "*_fastqc.zip"

    script:
    """
    fastqc $reads --threads ${task.cpus}
    """
}
