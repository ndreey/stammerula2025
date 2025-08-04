#!/usr/bin/env nextflow

include { longAssembly as LONG_ASSEMBLY_PROC } from '../modules/metamdbg.nf'

workflow LONG_ASSEMBLY {

    take:
        long_reads    // [meta, read]

    main:
        // Extract all reads and group them for the assembler
        collected_reads = long_reads.map { meta, read -> read }.collect()

        // Extract a representative sample/pop
        meta_info = long_reads.map { meta, read -> tuple(meta.pop, meta.sample) }.first()

        // Combine into tuple format: (pop, sample, [reads])
        assembly_input = meta_info.combine(collected_reads).map { pop, sample, reads ->
            tuple(pop, sample, reads)
        }

        LONG_ASSEMBLY_PROC(assembly_input)

    emit:
        long_metagenome = LONG_ASSEMBLY_PROC.out.long_metagenome
}
