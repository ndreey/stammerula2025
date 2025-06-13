#!/usr/bin/env nextflow

// Validate pair-end fastq files with aliases for different stages
include { VALIDATE_PE as VALIDATE_PE_RAW }              from '../modules/validate-fq.nf'
include { MERGE_VALI_RES as MERGE_VALI_RES_RAW }        from '../modules/validate-fq.nf'
include { VALIDATE_PE as VALIDATE_PE_TRIM }             from '../modules/validate-fq.nf'
include { MERGE_VALI_RES as MERGE_VALI_RES_TRIM }       from '../modules/validate-fq.nf'
include { VALIDATE_PE as VALIDATE_PE_DECON }            from '../modules/validate-fq.nf'
include { MERGE_VALI_RES as MERGE_VALI_RES_DECON }      from '../modules/validate-fq.nf'

// Sequence statistics with aliases for different stages
include { FASTQ_STATS as FASTQ_STATS_SR_RAW }           from '../modules/seq-stats.nf'
include { FASTQ_STATS as FASTQ_STATS_SR_TRIM }          from '../modules/seq-stats.nf'
include { FASTQ_STATS as FASTQ_STATS_SR_DECON }         from '../modules/seq-stats.nf'
include { FASTQ_STATS as FASTQ_STATS_LR_RAW }           from '../modules/seq-stats.nf'
include { FASTQ_STATS as FASTQ_STATS_LR_DECON }         from '../modules/seq-stats.nf'

workflow FASTQ_VALIDATION_STATS {

    take:
        short_reads_raw     // [meta, r1, r2] - raw short reads
        long_reads_raw      // [meta, read] - raw long reads
        short_reads_trim    // [meta, r1, r2] - trimmed short reads
        short_reads_decon   // [meta, r1, r2] - decontaminated short reads
        long_reads_decon    // [meta, read] - decontaminated long reads

    main:

        ////////////////////////////////////////////////////////////////////////////
        // Raw reads validation and statistics
        ////////////////////////////////////////////////////////////////////////////
        
        // Validate raw short reads
        short_reads_raw_validation = short_reads_raw.map { meta, r1, r2 -> 
            tuple(r1, r2, "sr-raw") 
        }
        
        VALIDATE_PE_RAW(short_reads_raw_validation)
        
        raw_validate_results = VALIDATE_PE_RAW.out.validate
            .collect()
            .map { files -> tuple(files, "sr-raw") }
        
        MERGE_VALI_RES_RAW(raw_validate_results)
        
        // Get stats of raw reads
        raw_sr = short_reads_raw
            .flatMap { meta, r1, r2 -> [r1, r2] }
            .collect()
            .map { files -> tuple(files, "sr-raw") }
        
        raw_lr = long_reads_raw
            .flatMap { meta, read -> [read] }
            .collect()
            .map { files -> tuple(files, "lr-raw") }
        
        FASTQ_STATS_SR_RAW(raw_sr)
        FASTQ_STATS_LR_RAW(raw_lr)

        ////////////////////////////////////////////////////////////////////////////
        // Trimmed reads validation and statistics
        ////////////////////////////////////////////////////////////////////////////
        
        // Validate trimmed reads
        short_reads_trim_validation = short_reads_trim.map { meta, r1, r2 -> 
            tuple(r1, r2, "sr-trim") 
        }
        
        VALIDATE_PE_TRIM(short_reads_trim_validation)
        
        trim_validate_results = VALIDATE_PE_TRIM.out.validate
            .collect()
            .map { files -> tuple(files, "sr-trim") }
        
        MERGE_VALI_RES_TRIM(trim_validate_results)
        
        // Get stats of trimmed reads
        trim_sr = short_reads_trim
            .flatMap { meta, r1, r2 -> [r1, r2] }
            .collect()
            .map { files -> tuple(files, "sr-trim") }
        
        FASTQ_STATS_SR_TRIM(trim_sr)

        ////////////////////////////////////////////////////////////////////////////
        // Decontaminated reads validation and statistics
        ////////////////////////////////////////////////////////////////////////////
        
        // Validate decontaminated reads
        short_reads_decon_validation = short_reads_decon.map { meta, r1, r2 -> 
            tuple(r1, r2, "sr-decon") 
        }
        
        VALIDATE_PE_DECON(short_reads_decon_validation)
        
        decon_validate_results = VALIDATE_PE_DECON.out.validate
            .collect()
            .map { files -> tuple(files, "sr-decon") }
        
        MERGE_VALI_RES_DECON(decon_validate_results)
        
        // Get stats of decontaminated reads
        decon_sr = short_reads_decon
            .flatMap { meta, r1, r2 -> [r1, r2] }
            .collect()
            .map { files -> tuple(files, "sr-decon") }
        
        decon_lr = long_reads_decon
            .flatMap { meta, read -> [read] }
            .collect()
            .map { files -> tuple(files, "lr-decon") }
        
        FASTQ_STATS_SR_DECON(decon_sr)
        FASTQ_STATS_LR_DECON(decon_lr)

    emit:
        // Validation results
        raw_validation = MERGE_VALI_RES_RAW.out.validate_csv
        trim_validation = MERGE_VALI_RES_TRIM.out.validate_csv
        decon_validation = MERGE_VALI_RES_DECON.out.validate_csv
        
        // Statistics results
        raw_stats_sr = FASTQ_STATS_SR_RAW.out.seq_stats_csv
        raw_stats_lr = FASTQ_STATS_LR_RAW.out.seq_stats_csv
        trim_stats = FASTQ_STATS_SR_TRIM.out.seq_stats_csv
        decon_stats_sr = FASTQ_STATS_SR_DECON.out.seq_stats_csv
        decon_stats_lr = FASTQ_STATS_LR_DECON.out.seq_stats_csv
}