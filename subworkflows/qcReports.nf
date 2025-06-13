#!/usr/bin/env nextflow

// FastQC and MultiQC reports with aliases for different stages
include { FASTQC as FASTQC_RAW }                        from '../modules/fastqc.nf'
include { FASTQC as FASTQC_CCS }                        from '../modules/fastqc.nf'
include { FASTQC as FASTQC_TRIM }                       from '../modules/fastqc.nf'
include { MULTIQC as MULTIQC_RAW }                      from '../modules/multiqc.nf'
include { MULTIQC as MULTIQC_CCS }                      from '../modules/multiqc.nf'
include { MULTIQC as MULTIQC_TRIM }                     from '../modules/multiqc.nf'
include { MULTIQC as MULTIQC_FASTP }                    from '../modules/multiqc.nf'

workflow QC_REPORTS {

    take:
        short_reads_raw     // [meta, r1, r2] - raw short reads
        long_reads_raw      // [meta, read] - raw long reads  
        trimmed_reads       // [meta, r1, r2] - trimmed short reads
        fastp_reports       // [meta, html, json] - fastp reports

    main:

        ////////////////////////////////////////////////////////////////////////////
        // Generate FastQC reports for raw short reads
        ////////////////////////////////////////////////////////////////////////////

        sr_raw_reads = short_reads_raw.flatMap { meta, r1, r2 -> 
            [ tuple(meta, r1), tuple(meta, r2) ] 
        }

        FASTQC_RAW(sr_raw_reads)

        multiqc_input_raw = FASTQC_RAW.out.fastqc_files
            .collect()
            .ifEmpty([])

        MULTIQC_RAW(multiqc_input_raw)

        ////////////////////////////////////////////////////////////////////////////
        // Generate FastQC reports for raw long reads (CCS)
        ////////////////////////////////////////////////////////////////////////////

        lr_reads = long_reads_raw.map { meta, read -> 
            tuple(meta, read) 
        }

        FASTQC_CCS(lr_reads)

        multiqc_input_ccs = FASTQC_CCS.out.fastqc_files
            .collect()
            .ifEmpty([])

        MULTIQC_CCS(multiqc_input_ccs)

        ////////////////////////////////////////////////////////////////////////////
        // Generate FastQC reports for trimmed short reads
        ////////////////////////////////////////////////////////////////////////////

        trimmed_reads_for_fastqc = trimmed_reads.flatMap { meta, r1_trim, r2_trim -> 
            [ tuple(meta, r1_trim), tuple(meta, r2_trim) ] 
        }

        FASTQC_TRIM(trimmed_reads_for_fastqc)

        multiqc_input_trim = FASTQC_TRIM.out.fastqc_files
            .collect()
            .ifEmpty([])

        MULTIQC_TRIM(multiqc_input_trim)

        ////////////////////////////////////////////////////////////////////////////
        // Generate MultiQC report for fastp reports
        ////////////////////////////////////////////////////////////////////////////

        multiqc_input_fastp = fastp_reports
            .map { meta, html, json -> json }
            .collect()

        MULTIQC_FASTP(multiqc_input_fastp)

    emit:
        fastqc_raw = FASTQC_RAW.out.fastqc_files
        fastqc_ccs = FASTQC_CCS.out.fastqc_files
        fastqc_trim = FASTQC_TRIM.out.fastqc_files
        multiqc_raw = MULTIQC_RAW.out.multiqc_report
        multiqc_ccs = MULTIQC_CCS.out.multiqc_report
        multiqc_trim = MULTIQC_TRIM.out.multiqc_report
        multiqc_fastp = MULTIQC_FASTP.out.multiqc_report
}