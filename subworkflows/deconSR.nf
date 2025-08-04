#!/usr/bin/env nextflow

/*
-------------------------------------------------------
 Subworkflow: DECON_SR
 Purpose: Remove competitive reference contamination from short reads
-------------------------------------------------------
*/

include { DECON_SR as DECON_SR_PROCESS } from '../modules/decon-sr.nf'

workflow DECON_SR {

    take:
        trimmed_reads
        comp_ref_dir
        comp_ref
        comp_headers

    main:

        DECON_SR_PROCESS(
            trimmed_reads,
            comp_ref_dir,
            comp_ref,
            comp_headers
        )

    emit:
        decon_sr_reads = DECON_SR_PROCESS.out.decon_sr_reads
}

