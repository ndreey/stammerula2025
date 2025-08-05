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

    log.info "STARTING: Stammerula 2025 Metagenomics Pipeline"
    log.info "Timestamp: ${params.timestamp}"

    // Run init subworkflow to prepare input data
    def init_outputs = INIT()

    // Destructure emitted channels
    def short_reads_ch      = init_outputs.short_reads
    def long_reads_ch       = init_outputs.long_reads
    def comp_ref_dir_ch     = init_outputs.comp_ref_dir
    def comp_ref_ch         = init_outputs.comp_ref
    def comp_headers_ch     = init_outputs.comp_headers

    log.info "COMPLETED: Input data initialization and validation"

    // Launch main analysis logic
    STAM_PIPELINE(
        short_reads_ch,
        long_reads_ch,
        comp_ref_dir_ch,
        comp_ref_ch,
        comp_headers_ch
    )
}

// Workflow completion handlers
workflow.onComplete {
    log.info "Pipeline execution completed at: ${new Date()}"
    log.info "Execution status: ${workflow.success ? 'SUCCESS' : 'FAILED'}"
    log.info "Execution duration: ${workflow.duration}"
    log.info "CPU hours: ${workflow.stats.computeTimeFmt ?: 'N/A'}"
    log.info "Peak memory usage: ${workflow.stats.peakMemory ?: 'N/A'}"
    
    if (workflow.success) {
        log.info "Results are available in the following directories:"
        log.info "  - Quality Control: results/00-QC/"
        log.info "  - Assemblies: results/05-metagenomes/"
        log.info "  - Refined Bins: results/06-metaWRAP-refined-bins/"
        log.info "  - Quality Assessment: results/07-bin-quality-assessment/"
        log.info "  - Statistics: results/stats/"
    }
}

workflow.onError {
    log.error "Pipeline execution stopped with the following message: ${workflow.errorMessage}"
    log.error "Failed process: ${workflow.errorReport}"
}