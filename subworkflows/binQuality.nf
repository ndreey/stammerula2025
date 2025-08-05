#!/usr/bin/env nextflow

include { GTDBTK }   from '../modules/gtdbtk.nf'
include { CHECKM2 }  from '../modules/checkm2.nf'
include { BUSCO }    from '../modules/busco.nf'
include { BAKTA }    from '../modules/bakta.nf'

workflow BIN_QUALITY {

    take:
        refined_bins    // [pop, refined_bins_dir]

    main:
        log.info "STARTING: Comprehensive bin quality assessment"
        
        // Run taxonomic classification with GTDB-Tk
        log.info "RUNNING: Taxonomic classification with GTDB-Tk"
        GTDBTK(refined_bins)

        // Run quality assessment with CheckM2
        log.info "RUNNING: Completeness and contamination assessment with CheckM2"
        CHECKM2(refined_bins)

        // Run completeness assessment with BUSCO
        log.info "RUNNING: Gene completeness assessment with BUSCO"
        BUSCO(refined_bins)

        // Run genome annotation with Bakta
        log.info "RUNNING: Genome annotation with Bakta"
        BAKTA(refined_bins)


    emit:
        gtdbtk_results  = GTDBTK.out.gtdbtk_results
        checkm2_results = CHECKM2.out.checkm2_results
        busco_results   = BUSCO.out.busco_results
        bakta_results   = BAKTA.out.bakta_results
}
