#!/usr/bin/env nextflow

include { metaWRAPbinning }                                     from '../modules/binning-metaWRAP.nf'
include { metaWRAPbinning as metaWRAPbinning_short}             from '../modules/binning-metaWRAP.nf'
include { binRefinement }                                       from '../modules/bin-refinement.nf'

workflow BINNING {

    take:
        long_metagenome    // [pop, sample, metagenome_file]
        short_metagenomes  // [pop_id, contigs.fa, contigs.fastg] 
        merged_pops        // [pop_id, r1, r2]
    
    main:
        
        // Long assembly binning logic
        // Extract population from the single long metagenome
        target_pop = long_metagenome.map { pop, sample, file -> pop }

        // Filter merged_pops for matching population
        matching_reads = merged_pops
            .combine(target_pop)
            .filter { pop_id, r1, r2, target -> pop_id == target }
            .map { pop_id, r1, r2, target -> tuple(r1, r2) }

        // Combine for binning
        bin_input_long = long_metagenome
            .combine(matching_reads)
            .map { pop, sample, metagenome, r1, r2 ->
                tuple("${pop}-${sample}", metagenome, r1, r2)
            }

        // Short assembly binning logic
        // Keep only pop and contigs.fa
        bin_short = short_metagenomes.map { pop_id, contigs_fa, contigs_fastg -> 
            tuple(pop_id, contigs_fa)
        }

        // Find the corresponding merged_pops based on pop
        bin_input_short = bin_short
            .combine(merged_pops, by: 0)  // Join by pop_id (first element)
            .map { pop_id, metagenome, r1, r2 ->
                tuple("${pop_id}", metagenome, r1, r2)
            }

        // Bin the metagenomes with corresponding groups
        metaWRAPbinning(bin_input_long)
        metaWRAPbinning_short(bin_input_short)

        // Combine the channels for refinement
        all_bins = metaWRAPbinning.out.bin_dirs.mix(metaWRAPbinning_short.out.bin_dirs)

        // Refine the produced bins
        binRefinement(all_bins)

    emit:
        refined_bins = binRefinement.out.refined_bins
}