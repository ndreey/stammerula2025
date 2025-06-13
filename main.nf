#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Stammerula 2025 - Master Thesis Pipeline
    Author: André Bourbonnais (ndreey)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { INIT }          from './subworkflows/init.nf'
include { STAM_PIPELINE } from './workflow/stam.nf'

// Generate timestamp to label results/output folders
params.timestamp = new Date().format('yyyyMMdd-HH-mm-ss')

workflow {

    // Run init subworkflow to prepare input data
    def init_outputs = INIT()

    // Destructure emitted channels
    def short_reads_ch      = init_outputs.short_reads
    def long_reads_ch       = init_outputs.long_reads
    def comp_ref_dir_ch     = init_outputs.comp_ref_dir
    def comp_ref_ch         = init_outputs.comp_ref
    def comp_headers_ch     = init_outputs.comp_headers

    // Launch main analysis logic
    STAM_PIPELINE(
        short_reads_ch,
        long_reads_ch,
        comp_ref_dir_ch,
        comp_ref_ch,
        comp_headers_ch
    )
}
