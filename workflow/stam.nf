#!/usr/bin/env nextflow

include { FASTQ_VALIDATION_STATS }      from '../subworkflows/controlFASTQ.nf'
include { QC_REPORTS }                  from '../subworkflows/qcReports.nf'
include { TRIM_READS }                  from '../subworkflows/trimReads.nf'
include { DECON_SR }                    from '../subworkflows/deconSR.nf'
include { DECON_LR }                    from '../subworkflows/deconLR.nf'
include { FILE_MERGER }                 from '../subworkflows/merger.nf'
include { META_ASSEMBLY }               from '../subworkflows/metaAssembly.nf'
include { BINNING }                     from '../subworkflows/binning.nf'

workflow STAM_PIPELINE {

    take:
        short_reads
        long_reads
        comp_ref_dir
        comp_ref
        comp_headers

    main:

        ////////////////////////////////////////////////////////////////////////////
        // 1. Trim reads
        ////////////////////////////////////////////////////////////////////////////

        TRIM_READS(short_reads)

        ////////////////////////////////////////////////////////////////////////////
        // 3. Decontaminate reads
        ////////////////////////////////////////////////////////////////////////////

        DECON_SR(
            TRIM_READS.out.trimmed_reads,
            comp_ref_dir,
            comp_ref,
            comp_headers
        )

        DECON_LR(
            long_reads,
            comp_ref_dir,
            comp_ref,
            comp_headers
        )

        ////////////////////////////////////////////////////////////////////////////
        // 4. Validation and statistics
        ////////////////////////////////////////////////////////////////////////////

        FASTQ_VALIDATION_STATS(
            short_reads,
            long_reads,
            TRIM_READS.out.trimmed_reads,
            DECON_SR.out.decon_sr_reads,
            DECON_LR.out.decon_lr_reads
        )

        ////////////////////////////////////////////////////////////////////////////
        // 5. QC Reports
        ////////////////////////////////////////////////////////////////////////////

        QC_REPORTS(
            short_reads,
            long_reads,
            TRIM_READS.out.trimmed_reads,
            TRIM_READS.out.fastp_reports
        )

        ////////////////////////////////////////////////////////////////////////////
        // 6. Merge and assemble
        ////////////////////////////////////////////////////////////////////////////

        FILE_MERGER(DECON_SR.out.decon_sr_reads)

        META_ASSEMBLY(
            FILE_MERGER.out.merged_pops,
            DECON_LR.out.decon_lr_reads
        )

        BINNING(
            META_ASSEMBLY.out.long_metagenome,
            FILE_MERGER.out.merged_pops
        )
}
