#!/usr/bin/env nextflow

include { mergeBySample }              from '../modules/merge-by-sample.nf'
//include { MERGE_VALI_RES as MERGE_VALI_RES_RAW }        from '../modules/stam-validatefq.nf'

workflow FILE_MERGER {

    take:
        decon_sr_reads

    main:

        mergeBySample {decon_sr_reads}



}