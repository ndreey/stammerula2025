#!/usr/bin/env nextflow

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Stammerula 2025 - Master Thesis Pipeline
    Author: André Bourbonnais (ndreey)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { STAM_PIPELINE }                       from './workflow/stam.nf'

params.timestamp = new Date().format('yyyyMMdd-HH-mm-ss')

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
                lane    : row.CELL
            ]
            tuple(meta, file(row.READ))
        }

    // Load contamination reference and headers from params
    comp_ref = Channel.value(file(params.references.comp.fasta))
    comp_headers = Channel.value(file(params.references.comp.headers))

    // Launch the main pipeline logic
    STAM_PIPELINE(
        short_reads_ch,
        long_reads_ch,
        comp_ref,
        comp_headers
    )
}
