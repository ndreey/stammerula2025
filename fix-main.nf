#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Stammerula 2025 - Master Thesis Pipeline
    Author: André Bourbonnais (ndreey)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { STAM_PIPELINE }                       from './workflow/stam.nf'

workflow {

    //Load short-read metadata from CSV
    short_reads_ch = Channel
        .fromPath(params.metadata.sr, checkIfExists: true)
        .splitCsv(header: true)
        .map { row ->
            def meta = [
                pop     : row.POP,
                hp      : row.HP,
                reg     : row.REG,
                reghp   : row.regHP,
                sample  : row.SAMPLE,
                lane    : row.LANE
            ]
            tuple(meta, file(row.READ1), file(row.READ2))
        }

    // Load long-read metadata from CSV
    long_reads_ch = Channel
        .fromPath(params.metadata.lr, checkIfExists: true)
        .splitCsv(header: true)
        .map { row ->
            def meta = [
                pop     : row.POP,
                sample  : row.SAMPLE,
                cell    : row.CELL
            ]
            tuple(meta, file(row.READ))
        }

    // Load contamination reference and headers from params
    def cont_ref      = file(params.references.contamination.fasta)
    def cont_headers  = file(params.references.contamination.headers)

    // Launch the main pipeline logic
    STAM_PIPELINE(
        short_reads_ch,
        long_reads_ch,
        cont_ref,
        cont_headers
    )
}
