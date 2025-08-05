#!/usr/bin/env nextflow

/*
-------------------------------------------------------
 Subworkflow: merge_by_sample
 Purpose: Merge decontaminated reads per sample
-------------------------------------------------------
*/

include { mergeBySample as MERGE_SAMPLE_PROC } from '../modules/merge-by-sample.nf'

workflow MERGE_BY_SAMPLE {

    take:
        decon_sr_reads  // tuple(meta, r1, r2)

    main:
        grouped_reads = decon_sr_reads
            .map { meta, r1, r2 -> tuple(meta.sample, meta, r1, r2) }
            .groupTuple(by: 0)
            .map { sample_id, metas, r1s, r2s ->
                def pop = metas[0].pop
                tuple(sample_id, pop, r1s, r2s)
            }

        MERGE_SAMPLE_PROC(grouped_reads)

    emit:
        sample_merged = MERGE_SAMPLE_PROC.out.sample_merged
}
