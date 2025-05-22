#!/usr/bin/env nextflow

process BWA_INDEX_COMP_REF {

    label 'bwa_index'
    tag "${comp_ref.simpleName}"

    publishDir 'data/comp_ref', mode: 'symlink', overwrite: false, pattern: "*.{amb,ann,bwt,pac,sa}"

    container params.images.QC

    input:
    path comp_ref

    output:
    tuple val(comp_ref.getSimpleName()), path("${comp_ref.simpleName}.*"), emit: comp_ref_index

    script:
    """
    bwa index ${comp_ref}
    """
}