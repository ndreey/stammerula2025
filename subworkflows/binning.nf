#!/usr/bin/env nextflow

include { metaWRAPbinning }                                     from '../modules/binning-metaWRAP.nf'

workflow BINNING {

    take:
        long_metagenome
        short_metagenomes  
        merged_pops        // This now contains population-level merged reads
    
    main:
        // Filter merged_pops to only include CHSK population
        chsk_reads = merged_pops
            .filter { pop_id, r1, r2 -> 
                pop_id == "CHSK"  // Only keep CHSK population reads
            }
            .map { pop_id, r1, r2 -> 
                tuple(r1, r2)  // Extract just the read files
            }

        // Combine long metagenome with CHSK short reads for binning
        bin_input = long_metagenome
            .combine(chsk_reads)
            .map { long_meta_tuple, r1, r2 ->
                // Extract the metagenome file from long_metagenome
                def metagenome_file = long_meta_tuple[1]  // Assuming [meta, file] structure
                tuple(metagenome_file, r1, r2)
            }

        metaWRAPbinning(bin_input)

    emit:
        bins = metaWRAPbinning.out.bin_dirs
}