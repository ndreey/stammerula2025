#!/usr/bin/env nextflow

/*
-------------------------------------------------------
 Subworkflow: TRIM
 Purpose: Trim adapters and low-quality bases using fastp
-------------------------------------------------------
*/

include { TRIM as TRIM_PROCESS } from '../modules/trim.nf'

workflow TRIM_READS {

    take:
        short_reads  // tuple(meta, read1, read2)

    main:
        log.info "STARTING: Read trimming and quality filtering with fastp"
        TRIM_PROCESS(short_reads)

    emit:
        trimmed_reads = TRIM_PROCESS.out.trimmed_reads
        fastp_reports = TRIM_PROCESS.out.fastp_reports
}
