#!/usr/bin/env nextflow

include { DB_SETUP }                             from '../subworkflows/db-setup.nf'
include { FASTQ_VALIDATION_STATS }               from '../subworkflows/control-fastq.nf'
include { QC_REPORTS }                           from '../subworkflows/qc_reports.nf'
include { READ_PROCESSING }                      from '../subworkflows/read_processing.nf'
include { FILE_MERGER }                          from '../subworkflows/merger.nf'
include { META_ASSEMBLY }                        from '../subworkflows/meta-assembly.nf'
include { BINNING }                              from '../subworkflows/binning.nf'

workflow STAM_PIPELINE {

    take:
        short_reads
        long_reads
        comp_ref
        comp_headers

    main:

        //DB_SETUP(comp_ref)

        ////////////////////////////////////////////////////////////////////////////
        // 1. Process reads (trimming and decontamination)
        ////////////////////////////////////////////////////////////////////////////

        READ_PROCESSING(
            short_reads,
            long_reads,
            comp_ref,
            comp_headers
        )

        ////////////////////////////////////////////////////////////////////////////
        // 2. Validation and statistics for all stages
        ////////////////////////////////////////////////////////////////////////////
        
        FASTQ_VALIDATION_STATS(
            short_reads,                               // short_reads_raw
            long_reads,                                // long_reads_raw
            READ_PROCESSING.out.trimmed_reads,         // short_reads_trim
            READ_PROCESSING.out.decon_sr_reads,        // short_reads_decon
            READ_PROCESSING.out.decon_lr_reads         // long_reads_decon
        )

        ////////////////////////////////////////////////////////////////////////////
        // 3. Generate QC reports
        ////////////////////////////////////////////////////////////////////////////

        QC_REPORTS(
            short_reads,                               // raw short reads
            long_reads,                                // raw long reads
            READ_PROCESSING.out.trimmed_reads,         // trimmed reads
            READ_PROCESSING.out.fastp_reports          // fastp reports
        )

        ////////////////////////////////////////////////////////////////////////////
        // 4. Merge decontaminated reads and continue with assembly/binning
        ////////////////////////////////////////////////////////////////////////////

        FILE_MERGER(
            READ_PROCESSING.out.decon_sr_reads
        )

        META_ASSEMBLY(
            FILE_MERGER.out.merged_pops,
            READ_PROCESSING.out.decon_lr_reads
        )

        BINNING(
            META_ASSEMBLY.out.long_metagenome,
            FILE_MERGER.out.merged_pops
        )

    //emit:
    //    bins = BINNING.out.bins
}