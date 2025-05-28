#!/usr/bin/env nextflow

include { metaWRAPbinning }                                     from '../modules/binning-metaWRAP.nf'
include { binRefinement }                                       from '../modules/bin-refinement.nf'

workflow BINNING {

    take:
        long_metagenome    // [pop, sample, metagenome_file] - single item  
        merged_pops        // [pop_id, r1, r2]
    
    main:
        // Extract population from the single long metagenome
        target_pop = long_metagenome.map { pop, sample, file -> pop }

        // Filter merged_pops for matching population
        matching_reads = merged_pops
            .combine(target_pop)
            .filter { pop_id, r1, r2, target -> pop_id == target }
            .map { pop_id, r1, r2, target -> tuple(r1, r2) }

        // Combine for binning
        bin_input = long_metagenome
            .combine(matching_reads)
            .map { pop, sample, metagenome, r1, r2 ->
                tuple("${pop}-${sample}", metagenome, r1, r2)
            }

        metaWRAPbinning(bin_input)

        // metaWRAPbinning output is exactly what binRefinement needs!
        binRefinement(metaWRAPbinning.out.bin_dirs)

    emit:
        raw_bins = metaWRAPbinning.out.bin_dirs
        refined_bins = binRefinement.out.refined_bins
}