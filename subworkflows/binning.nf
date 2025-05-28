#!/usr/bin/env nextflow

include { metaWRAPbinning }                                     from '../modules/binning-metaWRAP.nf'
include { binRefinement }                                       from '../modules/bin-refinement.nf'

workflow BINNING {

    take:
        long_metagenome    // [pop, sample, metagenome_file]
        short_metagenomes  
        merged_pops        // [pop_id, r1, r2]
    
    main:
        // Extract population from long metagenome
        target_pop = long_metagenome
            .map { pop, sample, metagenome_file -> pop }
            .first()

        // Filter merged_pops for matching population
        matching_reads = merged_pops
            .combine(target_pop)
            .filter { pop_id, r1, r2, target -> pop_id == target }
            .map { pop_id, r1, r2, target -> tuple(r1, r2) }

        // Combine for binning input
        bin_input = long_metagenome
            .combine(matching_reads)
            .map { pop, sample, metagenome, r1, r2 ->
                tuple("${pop}-${sample}", metagenome, r1, r2)
            }

        // Run binning
        metaWRAPbinning(bin_input)

        // Collect all bin directories for refinement
        refinement_input = target_pop
            .combine(metaWRAPbinning.out.concoct_bin_dir.map { id, dir -> dir })
            .combine(metaWRAPbinning.out.maxbin2_bin_dir.map { id, dir -> dir })
            .combine(metaWRAPbinning.out.metabat2_bin_dir.map { id, dir -> dir })

        // Run refinement
        binRefinement(refinement_input)

    emit:
        raw_bins = metaWRAPbinning.out
        refined_bins = binRefinement.out.refined_bins
}