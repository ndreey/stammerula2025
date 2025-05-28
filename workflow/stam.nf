#!/usr/bin/env nextflow

include { DB_SETUP }                             from '../subworkflows/db-setup.nf'
include { QC_PREPROCESSING }                        from '../subworkflows/qc_preprocessing.nf'
include { FILE_MERGER }                             from '../subworkflows/merger.nf'
include { META_ASSEMBLY }                           from '../subworkflows/meta-assembly.nf'
include { BINNING }                                 from '../subworkflows/binning.nf'

workflow STAM_PIPELINE {

    take:
        short_reads
        long_reads
        comp_ref
        comp_headers

    main:

        //DB_SETUP{comp_ref}

        QC_PREPROCESSING(
            short_reads,
            long_reads,
            comp_ref,
            comp_headers
        )

        // Merge decontaminated reads based on metadata
        FILE_MERGER(
            QC_PREPROCESSING.out.decon_sr_reads
        )
        META_ASSEMBLY(
            FILE_MERGER.out.merged_pops,
            QC_PREPROCESSING.out.decon_lr_reads
        )

        BINNING(
            META_ASSEMBLY.out.long_metagenome,
            FILE_MERGER.out.merged_pops
        )

    //emit:
    //    bins = BINNING.out.bins
}

