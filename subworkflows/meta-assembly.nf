#!/usr/bin/env nextflow

include { longAssembly }                                        from '../modules/metamdbg.nf'
include { shortAssembly }                                       from '../modules/megahit.nf'


workflow META_ASSEMBLY {

    take:
        pop_reads
        long_reads
    
    main:

        // Collect all long reads for metaMDBG assembly
        long_reads
            .map { meta, read -> read }
            .collect()
            .set { collected_lr }
        
        longAssembly(collected_lr)

        // Use population reads directly (now includes pop_id from mergeByPop)
        shortAssembly(pop_reads)

    emit:
        long_metagenome = longAssembly.out.long_metagenome
        short_metagenomes = shortAssembly.out.short_metagenomes
}