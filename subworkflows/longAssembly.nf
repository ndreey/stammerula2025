#!/usr/bin/env nextflow

include { longAssembly as LONG_ASSEMBLY_PROC } from '../modules/metamdbg.nf'

workflow LONG_ASSEMBLY {

    take:
        long_reads    // [meta, read]

    main:
        
        // Extract all reads and group them for the assembler
        collected_reads = long_reads.map { meta, read -> read }.collect()

        // Extract a representative sample/pop (since they're all the same)
        meta_info = long_reads.map { meta, read -> tuple(meta.pop, meta.sample) }.first()

        // Use cross instead of combine to avoid flattening
        assembly_input = meta_info.cross(collected_reads).map { meta_tuple, reads_list ->
            def pop = meta_tuple[0]
            def sample = meta_tuple[1]
            tuple(pop, sample, reads_list)
        }
          
        
        //assembly_input = meta_info.combine(collected_reads).map { pop, sample, reads ->
        //    tuple(pop, sample, reads)
        //}

        LONG_ASSEMBLY_PROC(assembly_input)

    emit:
        long_metagenome = LONG_ASSEMBLY_PROC.out.long_metagenome
}
