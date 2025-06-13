#!/usr/bin/env nextflow

/*
-------------------------------------------------------
 Subworkflow: INIT
 Purpose: Parse metadata & load reference input files
-------------------------------------------------------
*/

workflow INIT {

    main:

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
        .ifEmpty { error "❌ No short-read metadata entries found in: ${params.metadata.sr}" }

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
        .ifEmpty { error "❌ No long-read metadata entries found in: ${params.metadata.lr}" }

    comp_ref_dir_ch = Channel.value(file(params.references.comp.dir))
        .ifEmpty { error "❌ Competitive reference directory not found: ${params.references.comp.dir}" }

    comp_ref_name_ch = Channel.value(params.references.comp.fasta)
        .ifEmpty { error "❌ Competitive reference directory not found: ${params.references.comp.dir}" }


    comp_headers_ch = Channel.value(file(params.references.comp.headers))
        .ifEmpty { error "❌ Competitive reference headers not found: ${params.references.comp.headers}" }

    emit:
        short_reads     = short_reads_ch
        long_reads      = long_reads_ch
        comp_ref_dir    = comp_ref_dir_ch
        comp_ref        = comp_ref_name_ch
        comp_headers    = comp_headers_ch
}
