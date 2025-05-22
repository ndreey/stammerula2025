#!/usr/bin/env nextflow

process BWA_INDEX_COMP_REF {

    label 'bwa_index'
    tag "${comp_ref.simpleName}"

    publishDir 'data/comp_ref', mode: 'copy', overwrite: false, pattern: "*.{amb,ann,bwt,pac,sa}"

    container params.images.QC

    input:
    path comp_ref

    output:
    tuple path(comp_ref), path("${comp_ref.getName()}.*"), emit: comp_ref_files

    script:
    """
    bwa index ${comp_ref}
    """
}
