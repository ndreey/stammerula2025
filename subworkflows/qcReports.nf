#!/usr/bin/env nextflow

// FastQC and MultiQC reports with aliases for different stages
include { FASTQC as FASTQC_RAW }             from '../modules/fastqc.nf'
include { FASTQC as FASTQC_CCS }             from '../modules/fastqc.nf'
include { FASTQC as FASTQC_TRIM }            from '../modules/fastqc.nf'
include { FASTQC as FASTQC_SAMPLE_MERGED }   from '../modules/fastqc.nf'
include { FASTQC as FASTQC_POP_MERGED }      from '../modules/fastqc.nf'

include { MULTIQC as MULTIQC_RAW }           from '../modules/multiqc.nf'
include { MULTIQC as MULTIQC_CCS }           from '../modules/multiqc.nf'
include { MULTIQC as MULTIQC_TRIM }          from '../modules/multiqc.nf'
include { MULTIQC as MULTIQC_FASTP }         from '../modules/multiqc.nf'
include { MULTIQC as MULTIQC_SAMPLE }        from '../modules/multiqc.nf'
include { MULTIQC as MULTIQC_POP }           from '../modules/multiqc.nf'

workflow QC_REPORTS {

    take:
        short_reads_raw         // [meta, r1, r2]
        long_reads_raw          // [meta, read]
        trimmed_reads           // [meta, r1, r2]
        fastp_reports           // [meta, html, json]
        sample_merged_reads     // [sample_id, pop, r1, r2]
        pop_merged_reads        // [pop_id, r1, r2]

    main:
    ////////////////////////////////////////////////////////////////////////////////
    // Raw short reads
    ////////////////////////////////////////////////////////////////////////////////

    sr_raw_reads = short_reads_raw.flatMap { meta, r1, r2 -> 
        [ tuple(meta, r1), tuple(meta, r2) ] 
    }

    FASTQC_RAW(sr_raw_reads)
    MULTIQC_RAW(FASTQC_RAW.out.fastqc_files.collect().ifEmpty([]))

    ////////////////////////////////////////////////////////////////////////////////
    // Raw long reads
    ////////////////////////////////////////////////////////////////////////////////

    lr_reads = long_reads_raw.map { meta, read -> tuple(meta, read) }

    FASTQC_CCS(lr_reads)
    MULTIQC_CCS(FASTQC_CCS.out.fastqc_files.collect().ifEmpty([]))

    ////////////////////////////////////////////////////////////////////////////////
    // Trimmed short reads
    ////////////////////////////////////////////////////////////////////////////////

    trimmed_reads_for_fastqc = trimmed_reads.flatMap { meta, r1, r2 -> 
        [ tuple(meta, r1), tuple(meta, r2) ] 
    }

    FASTQC_TRIM(trimmed_reads_for_fastqc)
    MULTIQC_TRIM(FASTQC_TRIM.out.fastqc_files.collect().ifEmpty([]))

    ////////////////////////////////////////////////////////////////////////////////
    // Fastp JSON reports (used by MultiQC)
    ////////////////////////////////////////////////////////////////////////////////

    multiqc_input_fastp = fastp_reports.map { meta, html, json -> json }.collect()
    MULTIQC_FASTP(multiqc_input_fastp)

    ////////////////////////////////////////////////////////////////////////////////
    // Sample-merged reads
    ////////////////////////////////////////////////////////////////////////////////

    sample_merged_fastqc_input = sample_merged_reads.flatMap { sample, pop, r1, r2 ->
        def meta = [sample: sample, pop: pop, lane: "merged"]
        [ tuple(meta, r1), tuple(meta, r2) ]
    }

    FASTQC_SAMPLE_MERGED(sample_merged_fastqc_input)
    MULTIQC_SAMPLE(FASTQC_SAMPLE_MERGED.out.fastqc_files.collect().ifEmpty([]))

    ////////////////////////////////////////////////////////////////////////////////
    // Pop-merged reads
    ////////////////////////////////////////////////////////////////////////////////
 
    pop_merged_fastqc_input = pop_merged_reads.flatMap { pop, r1, r2 ->
        def meta = [sample: pop, pop: pop, lane: "merged"]
        [ tuple(meta, r1), tuple(meta, r2) ]
    }

    FASTQC_POP_MERGED(pop_merged_fastqc_input)
    MULTIQC_POP(FASTQC_POP_MERGED.out.fastqc_files.collect().ifEmpty([]))

    emit:
        fastqc_raw      = FASTQC_RAW.out.fastqc_files
        fastqc_ccs      = FASTQC_CCS.out.fastqc_files
        fastqc_trim     = FASTQC_TRIM.out.fastqc_files
        fastqc_sample   = FASTQC_SAMPLE_MERGED.out.fastqc_files
        fastqc_pop      = FASTQC_POP_MERGED.out.fastqc_files

        multiqc_raw     = MULTIQC_RAW.out.multiqc_report
        multiqc_ccs     = MULTIQC_CCS.out.multiqc_report
        multiqc_trim    = MULTIQC_TRIM.out.multiqc_report
        multiqc_fastp   = MULTIQC_FASTP.out.multiqc_report
        multiqc_sample  = MULTIQC_SAMPLE.out.multiqc_report
        multiqc_pop     = MULTIQC_POP.out.multiqc_report
}
