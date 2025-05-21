#!/usr/bin/env nextflow

process INDEX_MINIMAP2 {

	label 'index'
	tag "${ref.simpleName}"

    container params.images.QC
    
	input:
	path ref

	output:
	path "${ref.simpleName}.mmi", emit: minimap2_index

	when:
		!file("${ref.simpleName}.mmi").exists()

	script:
	"""
	minimap2 -d ${ref.simpleName}.mmi ${ref}
	"""
}