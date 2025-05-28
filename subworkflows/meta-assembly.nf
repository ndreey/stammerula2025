#!/usr/bin/env nextflow

include { longAssembly }                                        from '../modules/metamdbg.nf'
include { shortAssembly }                                       from '../modules/megahit.nf'

workflow META_ASSEMBLY {

    take:
        pop_reads      // From FILE_MERGER.out.merged_pops
        long_reads     // From QC_PREPROCESSING.out.decon_lr_reads
    
    main:
        // Collect all long reads for metaMDBG assembly
        collected_lr = long_reads
            .map { meta, read -> read }
            .collect()
      
        // Extract metadata from first long read (all are same pop/sample)
        meta_lr = long_reads
            .map { meta, read -> tuple(meta.pop, meta.sample) }
            .first()

        // Combine metadata and collected reads for longAssembly
        assembly_input = meta_lr
            .combine(collected_lr)
            .map { pop, sample, reads ->
                tuple(pop, sample, reads)
            }
        
        longAssembly(assembly_input)
        shortAssembly(pop_reads)

    emit:
        long_metagenome = longAssembly.out.long_metagenome
        //short_metagenomes = shortAssembly.out.short_metagenomes
}