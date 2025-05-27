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
        // Ensure all decontamination is complete before proceeding
        all_decon_reads = decon_sr_reads.collect().flatten().collate(3)

        // Group by sample - format for mergeBySample process
        sample_grouped = all_decon_reads
            .map { meta, r1, r2 -> 
                def sample_key = meta.sample
                tuple(sample_key, meta, r1, r2)
            }
            .groupTuple(by: 0)
            .map { sample_key, meta_list, r1_list, r2_list ->
                // Extract sample_id and pop for the process
                def sample_id = sample_key
                def pop = meta_list[0].pop  // All entries should have same pop for a sample
                tuple(sample_id, pop, r1_list, r2_list)
            }

        // Group by population - format for mergeByPop process
        pop_grouped = all_decon_reads
            .map { meta, r1, r2 -> 
                def pop_key = meta.pop
                tuple(pop_key, meta, r1, r2)
            }
            .groupTuple(by: 0)
            .map { pop_key, meta_list, r1_list, r2_list ->
                // Extract just pop_id for the process
                def pop_id = pop_key
                tuple(pop_id, r1_list, r2_list)
            }

        pop_grouped.view()
        // Perform merging
        mergeBySample(sample_grouped)
        mergeByPop(pop_grouped)

        // Validation for sample-merged files
        sample_validation_input = mergeBySample.out.sample_merged
            .map { files -> 
                def r1 = files.find { it.name.contains('_R1') }
                def r2 = files.find { it.name.contains('_R2') }
                tuple(r1, r2, "sample-merged")
            }

        VALIDATE_PE_SAMPLE(sample_validation_input)
        
        sample_validate_results = VALIDATE_PE_SAMPLE.out.validate
            .collect()
            .map { files -> tuple(files, "sample-merged") }

        MERGE_VALI_RES_SAMPLE(sample_validate_results)

        // Validation for population-merged files
        pop_validation_input = mergeByPop.out.pop_merged
            .map { pop_id, r1, r2 -> 
                tuple(r1, r2, "pop-merged")
            }

        VALIDATE_PE_POP(pop_validation_input)
        
        pop_validate_results = VALIDATE_PE_POP.out.validate
            .collect()
            .map { files -> tuple(files, "pop-merged") }

        MERGE_VALI_RES_POP(pop_validate_results)

        // Statistics collection
        sample_stats_input = mergeBySample.out.sample_merged
            .collect()
            .map { files -> tuple(files, "sample-merged") }

        FASTQ_STATS_SAMPLE_MERGED(sample_stats_input)

        pop_stats_input = mergeByPop.out.pop_merged
            .map { pop_id, r1, r2 -> [r1, r2] }
            .collect { it.flatten() }
            .map { files -> tuple(files, "pop-merged") }

        FASTQ_STATS_POP_MERGED(pop_stats_input)

    emit:
        merged_reads = mergeBySample.out.sample_merged
        merged_pops = mergeByPop.out.pop_merged
        sample_validation = MERGE_VALI_RES_SAMPLE.out.validate_csv
        pop_validation = MERGE_VALI_RES_POP.out.validate_csv
        sample_stats = FASTQ_STATS_SAMPLE_MERGED.out.seq_stats_csv
        pop_stats = FASTQ_STATS_POP_MERGED.out.seq_stats_csv
}