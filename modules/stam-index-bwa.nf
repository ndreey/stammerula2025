#!/usr/bin/env nextflow

process BWA_INDEX_COMP_REF {

    label 'bwa_index'
    tag "${comp_ref.simpleName}"

    publishDir 'data/comp_ref', mode: 'copy', overwrite: false, pattern: "*.{amb,ann,bwt,pac,sa}"

    container params.images.ALIGN

    input:
    path comp_ref

    output:
    path("*.{amb,ann,bwt,pac,sa}"), emit: comp_idx

    script:
    """
    bwa index ${comp_ref}
    """
}
