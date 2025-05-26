#!/usr/bin/env nextflow






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