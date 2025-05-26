#!/usr/bin/env nextflow

include { mergeBySample }              from '../modules/merge-by-sample.nf'
include { mergeByPop }                 from '../modules/merge-by-pop.nf'

workflow FILE_MERGER {

    take:
        decon_sr_reads

    main:

        // Group decontaminated reads by sample and collect all files per sample
        decon_sr_reads
            .map { meta, r1, r2 -> 
                tuple(meta.sample, meta.pop, r1, r2)
            }
            .groupTuple(by: 0)  // Group by sample
            .map { sample_id, pop_list, r1_list, r2_list ->
                // Take the first pop value since all is the same for a sample
                tuple(sample_id, pop_list[0], r1_list, r2_list)
            }
            .set { grouped_reads }

        mergeBySample(grouped_reads)

        // Group decontaminated reads by population and collect all files per population
        decon_sr_reads
            .map { meta, r1, r2 -> 
                tuple(meta.pop, r1, r2)
            }
            .groupTuple(by: 0)  // Group by population
            .map { pop_id, r1_list, r2_list ->
                tuple(pop_id, r1_list, r2_list)
            }
            .set { grouped_by_pop }

        mergeByPop(grouped_by_pop)

    emit:
        merged_reads = mergeBySample.out.sample_merged
        merged_pops = mergeByPop.out.pop_merged
}