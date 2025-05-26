#!/usr/bin/env nextflow

// Merge fastq files
include { mergeBySample }                               from '../modules/merge-by-sample.nf'
include { mergeByPop }                                  from '../modules/merge-by-pop.nf'

// Validate merger
include { VALIDATE_PE as VALIDATE_PE_SAMPLE }           from '../modules/validate-fq.nf'
include { VALIDATE_PE as VALIDATE_PE_POP }              from '../modules/validate-fq.nf'
include { MERGE_VALI_RES as MERGE_VALI_RES_SAMPLE }     from '../modules/validate-fq.nf'
include { MERGE_VALI_RES as MERGE_VALI_RES_POP }        from '../modules/validate-fq.nf'

// FASTQ Statistics
include { FASTQ_STATS as FASTQ_STATS_SAMPLE_MERGED }    from '../modules/seq-stats.nf'
include { FASTQ_STATS as FASTQ_STATS_POP_MERGED }       from '../modules/seq-stats.nf'


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

        // Validate merged sample reads (simplified - no metadata needed)
        mergeBySample.out.sample_merged
            .map { files -> 
                def r1 = files.find { it.name.contains('_R1') }
                def r2 = files.find { it.name.contains('_R2') }
                tuple(r1, r2, "sample-merged")
            }
            .set { sample_validation_input }

        VALIDATE_PE_SAMPLE(sample_validation_input)

        VALIDATE_PE_SAMPLE.out.validate
            .collect()
            .map { files -> tuple(files, "sample-merged") }
            .set { sample_validate_results }

        MERGE_VALI_RES_SAMPLE(sample_validate_results)

        // Validate merged population reads (simplified - no metadata needed)
        mergeByPop.out.pop_merged
            .map { pop_id, r1, r2 -> 
                tuple(r1, r2, "pop-merged")
            }
            .set { pop_validation_input }

        VALIDATE_PE_POP(pop_validation_input)

        VALIDATE_PE_POP.out.validate
            .collect()
            .map { files -> tuple(files, "pop-merged") }
            .set { pop_validate_results }

        MERGE_VALI_RES_POP(pop_validate_results)

        // Get statistics for sample-merged files
        mergeBySample.out.sample_merged
            .collect()
            .map { files -> tuple(files, "sample-merged") }
            .set { sample_stats_input }

        FASTQ_STATS_SAMPLE_MERGED(sample_stats_input)

        // Get statistics for population-merged files
        mergeByPop.out.pop_merged
            .map { pop_id, r1, r2 -> [r1, r2] }
            .flatten()
            .collect()
            .map { files -> tuple(files, "pop-merged") }
            .set { pop_stats_input }

        FASTQ_STATS_POP_MERGED(pop_stats_input)

    emit:
        merged_reads = mergeBySample.out.sample_merged
        merged_pops = mergeByPop.out.pop_merged
        sample_validation = MERGE_VALI_RES_SAMPLE.out.validate_csv
        pop_validation = MERGE_VALI_RES_POP.out.validate_csv
        sample_stats = FASTQ_STATS_SAMPLE_MERGED.out.seq_stats_csv
        pop_stats = FASTQ_STATS_POP_MERGED.out.seq_stats_csv
}