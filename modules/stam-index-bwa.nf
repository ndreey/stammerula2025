#!/usr/bin/env nextflow

process BWA_INDEX_CONT_REF {

	label 'bwa_index'
	tag "${cont_ref.simpleName}"

    container params.images.QC

	input:
	path cont_ref

	output:
	tuple val(cont_ref.simpleName), path("${cont_ref.simpleName}.*"), emit: cont_ref_index

	when:
		!file("${cont_ref}.bwt").exists()

	script:
	"""
	bwa index ${cont_ref}
	"""
}


