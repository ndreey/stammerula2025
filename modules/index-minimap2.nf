#!/usr/bin/env nextflow

process INDEX_MINIMAP2 {

    label 'minimap2_index'
    tag "${comp_ref.simpleName}"

    publishDir 'data/comp_ref', mode: 'copy', overwrite: false, pattern: "*.mmi"

    container params.images.ALIGN

    input:
    path comp_ref

    output:
    path("*.mmi"), emit: comp_mmi

	script:
	"""
	minimap2 -x map-hifi -d ${comp_ref}.mmi \\
    	--split-prefix ${comp_ref.simpleName}-split \\
    	${comp_ref}
	"""
}