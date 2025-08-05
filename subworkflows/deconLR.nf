#!/usr/bin/env nextflow

/*
-------------------------------------------------------
 Subworkflow: DECON_LR
 Purpose: Remove competitive reference contamination from long reads
-------------------------------------------------------
*/

include { DECON_LR as DECON_LR_PROCESS } from '../modules/decon-lr.nf'

workflow DECON_LR {

    take:
        long_reads
        comp_ref_dir
        comp_ref
        comp_headers

    main:
        DECON_LR_PROCESS(
            long_reads,
            comp_ref_dir,
            comp_ref,
            comp_headers
        )

    emit:
        decon_lr_reads = DECON_LR_PROCESS.out.decon_lr_reads
}

