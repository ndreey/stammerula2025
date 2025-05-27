#!/usr/bin/env nextflow

include { setupCheckM }                                        from '../modules/checkm-db.nf'
include { setupCheckM2 }                                       from '../modules/checkm2-db.nf'


workflow DB_SETUP {

    take:
        must_it_take
    
    main:
        setupCheckM(must_it_take)      



    emit:
        setupCheckM.out.checkmdb



}