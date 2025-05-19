#!/usr/bin/env nextflow

process MULTIQC {

    label "qc"

    tag "multiqc"

    container params.images.QC

    input:
    path fastqc_dir

    output:
    path "multiqc_report.html"
    path "multiqc_data"

    script:
    """
    multiqc $fastqc_dir
    """
}


