#!/usr/bin/env nextflow

include { longAssembly }                                        from '../modules/metamdbg.nf'
include { shortssembly }                                        from '../modules/megahit.nf'


workflow META_ASSEMBLY {

    take:
        pop_reads
        long_reads
    
    main:

        long_reads
            .map { meta, read -> [read]}
            .collect()
            .set ( collected_lr )
        
        longAssembly(collected_lr)




}