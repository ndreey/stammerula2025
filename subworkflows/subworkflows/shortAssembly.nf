#!/usr/bin/env nextflow

include { shortAssembly as SHORT_ASSEMBLY_PROC } from '../modules/megahit.nf'

workflow SHORT_ASSEMBLY {

    take:
        pop_reads  // [pop_id, r1, r2]

    main:
        SHORT_ASSEMBLY_PROC(pop_reads)

    emit:
        short_metagenomes = SHORT_ASSEMBLY_PROC.out.short_metagenomes
}
