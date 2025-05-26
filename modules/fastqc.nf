#!/usr/bin/env nextflow

process FASTQC {

    label "qc"
    tag "${meta.sample}_${meta.lane}"

    container params.images.QC

    input:
    tuple val(meta), path(read)

    output:
    path "*_fastqc.{html,zip}", emit: fastqc_files

    script:
    """
    fastqc $read --threads ${task.cpus}
    """
}



