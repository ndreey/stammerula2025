#!/usr/bin/env nextflow

process TRIM {

    tag "${sample_id}"

    publishDir params.res.trim, mode: 'symlink'

    container params.images.QC

    input:
    tuple val(sample_id), path(read1), path(read2)

    output:
    tuple val(sample_id),
          path("${sample_id}_R1_trimmed.fastq.gz"),
          path("${sample_id}_R2_trimmed.fastq.gz"),
          path("${sample_id}-fastp.html"),
          path("${sample_id}-fastp.json")

    script:
    """
    fastp \
      --in1 ${read1} \
      --in2 ${read2} \
      --out1 ${sample_id}_R1_trimmed.fastq.gz \
      --out2 ${sample_id}_R2_trimmed.fastq.gz \
      --html ${sample_id}-fastp.html \
      --json ${sample_id}-fastp.json \
      --thread ${task.cpus} \
      --average_qual ${params.trim.avg_qual} \
      --length_required ${params.trim.len_req} \
      --trim_poly_x \
      --detect_adapter_for_pe \
      --dedup
    """
}
