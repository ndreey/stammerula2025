#!/usr/bin/env nextflow

include { longAssembly as LONG_ASSEMBLY_PROC } from '../modules/metamdbg.nf'

workflow LONG_ASSEMBLY {

    take:
        long_reads    // [meta, read]

    main:
        
        // Debug: Print what we're receiving
        long_reads.view { meta, read -> 
            "[INFO] Long read input: pop=${meta.pop}, sample=${meta.sample}, cell=${meta.cell}, read=${read}" 
        }

        // Prepare the assembly input for each pop-sample grouping.
        assembly_input = long_reads
            .map { meta, read -> 
                tuple(meta.pop, meta.sample, read)  // Group by pop AND sample
            }
            .groupTuple(by: [0, 1])  // Group by both population (index 0) and sample (index 1)
            .view { pop, sample, reads -> 
                "[INFO] Assembly starting: pop=${pop}, sample=${sample}, reads=${reads.size()} files" 
            }

        LONG_ASSEMBLY_PROC(assembly_input)

    emit:
        long_metagenome = LONG_ASSEMBLY_PROC.out.long_metagenome
}
