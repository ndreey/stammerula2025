#!/usr/bin/env nextflow

/*
-------------------------------------------------------
 Subworkflow: merge_by_pop
 Purpose: Merge decontaminated reads per population
-------------------------------------------------------
*/

include { mergeByPop as MERGE_POP_PROC } from '../modules/merge-by-pop.nf'

workflow MERGE_BY_POP {

    take:
        decon_sr_reads  // tuple(meta, r1, r2)

    main:
        grouped_reads = decon_sr_reads
            .map { meta, r1, r2 -> tuple(meta.pop, meta, r1, r2) }
            .groupTuple(by: 0)
            .map { pop_id, metas, r1s, r2s ->
                tuple(pop_id, r1s, r2s)
            }

        MERGE_POP_PROC(grouped_reads)

    emit:
        pop_merged = MERGE_POP_PROC.out.pop_merged
}
