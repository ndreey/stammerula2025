#!/usr/bin/env nextflow

include { longAssembly }                                        from '../modules/metamdbg.nf'
include { shortAssembly }                                       from '../modules/megahit.nf'


workflow META_ASSEMBLY {

    take:
        long_metagenome
        short_metagenomes
        merged_reads
    
    main:

        




}