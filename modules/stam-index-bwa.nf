#!/usr/bin/env nextflow

process BWA_INDEX_CONT_REF {

	label 'bwa_index'
	tag "${cont_ref.simpleName}"

	publishDir 'data/comp_ref', mode: 'symlink', overwrite: false, pattern: "!*.fasta.gz"

    container params.images.QC

	input:
	path cont_ref

	output:
	tuple val(cont_ref.simpleName), path("${cont_ref.simpleName}.*"), emit: cont_ref_index

	script:
	"""
	bwa index ${cont_ref}
	"""
}


