#!/usr/bin/env nextflow


include { QC_PREPROCESSING }        from '../subworkflows/qc_preprocessing.nf'
//include { ASSEMBLY }                from '../subworkflows/assembly.nf'
//include { BINNING }                 from '../subworkflows/binning.nf'

workflow STAM_PIPELINE {

    take:
        short_reads
        long_reads
        comp_ref
        comp_headers

    main:

        QC_PREPROCESSING(
            short_reads,
            long_reads,
            comp_ref,
            comp_headers
        )

        //ASSEMBLY(
        //    decont_trimmed_reads : QC_PREPROCESSING.out.decont_trimmed_reads,
        //    long_reads           : QC_PREPROCESSING.out.long_reads,
        //    metadata             : QC_PREPROCESSING.out.metadata
        //)

        //BINNING(
        //    assemblies           : ASSEMBLY.out.assemblies,
        //    decont_trimmed_reads : QC_PREPROCESSING.out.decont_trimmed_reads,
        //    metadata             : ASSEMBLY.out.meta
        //)

    //emit:
    //    bins = BINNING.out.bins
}

