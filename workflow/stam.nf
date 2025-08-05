#!/usr/bin/env nextflow

include { TRIM_READS }                  from '../subworkflows/trimReads.nf'
include { DECON_SR }                    from '../subworkflows/deconSR.nf'
include { DECON_LR }                    from '../subworkflows/deconLR.nf'
include { MERGE_BY_SAMPLE }             from '../subworkflows/mergeBySample.nf'
include { MERGE_BY_POP }                from '../subworkflows/mergeByPop.nf'
include { FASTQ_VALIDATION_STATS }      from '../subworkflows/controlFASTQ.nf'
include { QC_REPORTS }                  from '../subworkflows/qcReports.nf'
include { BINNING }                     from '../subworkflows/binning.nf'
include { SHORT_ASSEMBLY }              from '../subworkflows/shortAssembly.nf'
include { LONG_ASSEMBLY }               from '../subworkflows/longAssembly.nf'
include { BIN_QUALITY }                 from '../subworkflows/binQuality.nf'

workflow STAM_PIPELINE {

    take:
        short_reads
        long_reads
        comp_ref_dir
        comp_ref
        comp_headers

    main:

        ////////////////////////////////////////////////////////////////////////////
        // 1. Trim
        ////////////////////////////////////////////////////////////////////////////
        TRIM_READS(short_reads)

        ////////////////////////////////////////////////////////////////////////////
        // 2. Decontamination
        ////////////////////////////////////////////////////////////////////////////
        DECON_SR(TRIM_READS.out.trimmed_reads, comp_ref_dir, comp_ref, comp_headers)
        DECON_LR(long_reads, comp_ref_dir, comp_ref, comp_headers)

        ////////////////////////////////////////////////////////////////////////////
        // 3. Merge decontaminated short reads
        ////////////////////////////////////////////////////////////////////////////
        MERGE_BY_SAMPLE(DECON_SR.out.decon_sr_reads)
        MERGE_BY_POP(DECON_SR.out.decon_sr_reads)

        ////////////////////////////////////////////////////////////////////////////
        // 4. Stats and QC
        ////////////////////////////////////////////////////////////////////////////
        FASTQ_VALIDATION_STATS(
            short_reads,
            long_reads,
            TRIM_READS.out.trimmed_reads,
            DECON_SR.out.decon_sr_reads,
            DECON_LR.out.decon_lr_reads,
            MERGE_BY_SAMPLE.out.sample_merged,
            MERGE_BY_POP.out.pop_merged
        )

        QC_REPORTS(
            short_reads,
            long_reads,
            TRIM_READS.out.trimmed_reads,
            TRIM_READS.out.fastp_reports,
            MERGE_BY_SAMPLE.out.sample_merged,
            MERGE_BY_POP.out.pop_merged
        )

        ////////////////////////////////////////////////////////////////////////////
        // 5. Assembly
        ////////////////////////////////////////////////////////////////////////////
        SHORT_ASSEMBLY(MERGE_BY_POP.out.pop_merged)
        LONG_ASSEMBLY(DECON_LR.out.decon_lr_reads)

        ////////////////////////////////////////////////////////////////////////////
        // 6. Binning
        ////////////////////////////////////////////////////////////////////////////
        BINNING(
            LONG_ASSEMBLY.out.long_metagenome,
            MERGE_BY_POP.out.pop_merged
        )

        ////////////////////////////////////////////////////////////////////////////
        // 7. Bin Quality Assessment
        ////////////////////////////////////////////////////////////////////////////
        BIN_QUALITY(BINNING.out.refined_bins)

        
        // Workflow completion messages
        TRIM_READS.out.trimmed_reads.subscribe { 
            log.info "COMPLETED: Read trimming and quality filtering"
        }

        DECON_SR.out.decon_sr_reads.subscribe { 
            log.info "COMPLETED: Short-read decontamination"
        }

        DECON_LR.out.decon_lr_reads.subscribe { 
            log.info "COMPLETED: Long-read decontamination"
        }

        MERGE_BY_SAMPLE.out.sample_merged.subscribe { 
            log.info "COMPLETED: Sample-level read merging"
        }

        MERGE_BY_POP.out.pop_merged.subscribe { 
            log.info "COMPLETED: Population-level read merging"
        }

        SHORT_ASSEMBLY.out.short_metagenomes.subscribe { 
            log.info "COMPLETED: Short-read metagenome assembly (MEGAHIT)"
        }

        LONG_ASSEMBLY.out.long_metagenome.subscribe { 
            log.info "COMPLETED: Long-read metagenome assembly (metaMDBG)"
        }

        BINNING.out.refined_bins.subscribe { 
            log.info "COMPLETED: Metagenomic binning and refinement"
        }

        BIN_QUALITY.out.gtdbtk_results.subscribe { 
            log.info "COMPLETED: Bin quality assessment and annotation"
        }
}
