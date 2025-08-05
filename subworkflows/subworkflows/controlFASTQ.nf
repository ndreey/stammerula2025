#!/usr/bin/env nextflow

// Validation
include { VALIDATE_PE as VALIDATE_PE_RAW }                from '../modules/validate-fq.nf'
include { MERGE_VALI_RES as MERGE_VALI_RES_RAW }          from '../modules/validate-fq.nf'

include { VALIDATE_PE as VALIDATE_PE_TRIM }               from '../modules/validate-fq.nf'
include { MERGE_VALI_RES as MERGE_VALI_RES_TRIM }         from '../modules/validate-fq.nf'

include { VALIDATE_PE as VALIDATE_PE_DECON }              from '../modules/validate-fq.nf'
include { MERGE_VALI_RES as MERGE_VALI_RES_DECON }        from '../modules/validate-fq.nf'

include { VALIDATE_PE as VALIDATE_PE_SAMPLE_MERGE }       from '../modules/validate-fq.nf'
include { MERGE_VALI_RES as MERGE_VALI_RES_SAMPLE_MERGE } from '../modules/validate-fq.nf'

include { VALIDATE_PE as VALIDATE_PE_POP_MERGE }          from '../modules/validate-fq.nf'
include { MERGE_VALI_RES as MERGE_VALI_RES_POP_MERGE }    from '../modules/validate-fq.nf'

// Stats
include { FASTQ_STATS as FASTQ_STATS_SR_RAW }             from '../modules/seq-stats.nf'
include { FASTQ_STATS as FASTQ_STATS_LR_RAW }             from '../modules/seq-stats.nf'

include { FASTQ_STATS as FASTQ_STATS_SR_TRIM }            from '../modules/seq-stats.nf'
include { FASTQ_STATS as FASTQ_STATS_SR_DECON }           from '../modules/seq-stats.nf'
include { FASTQ_STATS as FASTQ_STATS_LR_DECON }           from '../modules/seq-stats.nf'

include { FASTQ_STATS as FASTQ_STATS_SAMPLE_MERGE }       from '../modules/seq-stats.nf'
include { FASTQ_STATS as FASTQ_STATS_POP_MERGE }          from '../modules/seq-stats.nf'

workflow FASTQ_VALIDATION_STATS {

    take:
        short_reads_raw
        long_reads_raw
        short_reads_trim
        short_reads_decon
        long_reads_decon
        short_reads_sample_merged
        short_reads_pop_merged

    main:

    ////////////////////////////////////////////////////////////////////////////////
    // Raw reads
    ////////////////////////////////////////////////////////////////////////////////

    VALIDATE_PE_RAW(short_reads_raw.map { m, r1, r2 -> tuple(r1, r2, "sr-raw") })
    MERGE_VALI_RES_RAW(VALIDATE_PE_RAW.out.validate.collect().map { f -> tuple(f, "sr-raw") })

    FASTQ_STATS_SR_RAW(short_reads_raw.flatMap { m, r1, r2 -> [r1, r2] }.collect().map { f -> tuple(f, "sr-raw") })
    FASTQ_STATS_LR_RAW(long_reads_raw.map { m, read -> read }.collect().map { f -> tuple(f, "lr-raw") })

    ////////////////////////////////////////////////////////////////////////////////
    // Trimmed
    ////////////////////////////////////////////////////////////////////////////////

    VALIDATE_PE_TRIM(short_reads_trim.map { m, r1, r2 -> tuple(r1, r2, "sr-trim") })
    MERGE_VALI_RES_TRIM(VALIDATE_PE_TRIM.out.validate.collect().map { f -> tuple(f, "sr-trim") })

    FASTQ_STATS_SR_TRIM(short_reads_trim.flatMap { m, r1, r2 -> [r1, r2] }.collect().map { f -> tuple(f, "sr-trim") })

    ////////////////////////////////////////////////////////////////////////////////
    // Decontaminated
    ////////////////////////////////////////////////////////////////////////////////

    VALIDATE_PE_DECON(short_reads_decon.map { m, r1, r2 -> tuple(r1, r2, "sr-decon") })
    MERGE_VALI_RES_DECON(VALIDATE_PE_DECON.out.validate.collect().map { f -> tuple(f, "sr-decon") })

    FASTQ_STATS_SR_DECON(short_reads_decon.flatMap { m, r1, r2 -> [r1, r2] }.collect().map { f -> tuple(f, "sr-decon") })
    FASTQ_STATS_LR_DECON(long_reads_decon.map { m, read -> read }.collect().map { f -> tuple(f, "lr-decon") })

    ////////////////////////////////////////////////////////////////////////////////
    // Merged by sample
    ////////////////////////////////////////////////////////////////////////////////
    VALIDATE_PE_SAMPLE_MERGE(short_reads_sample_merged.map { sample_id, pop, r1, r2 -> tuple(r1, r2, "sample-merged") })
    MERGE_VALI_RES_SAMPLE_MERGE(VALIDATE_PE_SAMPLE_MERGE.out.validate.collect().map { f -> tuple(f, "sample-merged") })

    FASTQ_STATS_SAMPLE_MERGE(short_reads_sample_merged.flatMap { sample_id, pop, r1, r2 -> [r1, r2] }.collect().map { f -> tuple(f, "sample-merged") })

    //VALIDATE_PE_SAMPLE_MERGE(short_reads_sample_merged.map { m, r1, r2 -> tuple(r1, r2, "sample-merged") })
    //MERGE_VALI_RES_SAMPLE_MERGE(VALIDATE_PE_SAMPLE_MERGE.out.validate.collect().map { f -> tuple(f, "sample-merged") })

    //FASTQ_STATS_SAMPLE_MERGE(short_reads_sample_merged.flatMap { m, r1, r2 -> [r1, r2] }.collect().map { f -> tuple(f, "sample-merged") })

    ////////////////////////////////////////////////////////////////////////////////
    // Merged by population
    ////////////////////////////////////////////////////////////////////////////////

    VALIDATE_PE_POP_MERGE(short_reads_pop_merged.map { m, r1, r2 -> tuple(r1, r2, "pop-merged") })
    MERGE_VALI_RES_POP_MERGE(VALIDATE_PE_POP_MERGE.out.validate.collect().map { f -> tuple(f, "pop-merged") })

    FASTQ_STATS_POP_MERGE(short_reads_pop_merged.flatMap { m, r1, r2 -> [r1, r2] }.collect().map { f -> tuple(f, "pop-merged") })

    emit:
        raw_validation      = MERGE_VALI_RES_RAW.out.validate_csv
        trim_validation     = MERGE_VALI_RES_TRIM.out.validate_csv
        decon_validation    = MERGE_VALI_RES_DECON.out.validate_csv
        sample_validation   = MERGE_VALI_RES_SAMPLE_MERGE.out.validate_csv
        pop_validation      = MERGE_VALI_RES_POP_MERGE.out.validate_csv

        raw_stats_sr        = FASTQ_STATS_SR_RAW.out.seq_stats_csv
        raw_stats_lr        = FASTQ_STATS_LR_RAW.out.seq_stats_csv
        trim_stats          = FASTQ_STATS_SR_TRIM.out.seq_stats_csv
        decon_stats_sr      = FASTQ_STATS_SR_DECON.out.seq_stats_csv
        decon_stats_lr      = FASTQ_STATS_LR_DECON.out.seq_stats_csv
        sample_stats        = FASTQ_STATS_SAMPLE_MERGE.out.seq_stats_csv
        pop_stats           = FASTQ_STATS_POP_MERGE.out.seq_stats_csv
}
