#!/usr/bin/env nextflow

process DECON_SR {

	label "decon"

	tag "${sample_id}"

	publishDir "${params.res.decon}/clean-reads", mode: 'symlink', pattern: '*_R{1,2}-clean.fq.gz'

	container params.images.QC

	input:
	tuple val(sample_id), path(read1), path(read2)

	output:
	tuple val(sample_id),
		path("${sample_id}_R1-clean.fq.gz"),
		path("${sample_id}_R2-clean.fq.gz"),
		path("${sample_id}_singletons.fq.gz"),
		emit: decon_reads

	script:
	"""
	# Output file names
	CONT_BAM="${sample_id}.cont.sorted.bam"
	CONT_TXT="${sample_id}-cont-reads.txt"
	CLEAN_RAW_BAM="${sample_id}-clean.bam"
	CLEAN_SORTED_BAM="${sample_id}-clean.sorted.bam"
	R1_OUT="${sample_id}_R1-clean.fq.gz"
	R2_OUT="${sample_id}_R2-clean.fq.gz"
	SINGLETONS_OUT="${sample_id}_singletons.fq.gz"

	# Align to contamination reference
	bwa mem \\
		-R "@RG\\tID:${sample_id}\\tSM:${sample_id}\\tPL:ILLUMINA" \\
		-t ${task.cpus} ${params.decon.cont_ref} ${read1} ${read2} | \\
		samtools view -h -b -@ ${task.cpus} | \\
		samtools sort -@ ${task.cpus} --write-index -o \$CONT_BAM -

	# Extract contaminant read IDs
	samtools view -@ ${task.cpus} -f 3 -F 12 -q 20 \$CONT_BAM \$(cat ${params.decon.cont_headers}) | \\
		awk '{print \$1}' | sort | uniq > \$CONT_TXT

	# Filter out contaminated reads
	samtools view -h -@ ${task.cpus} \$CONT_BAM | \\
		grep -F -v -f \$CONT_TXT | \\
		samtools view -h -@ ${task.cpus} -b -o \$CLEAN_RAW_BAM -

	# Sort for fastq extraction
	samtools sort -n -@ ${task.cpus} -o \$CLEAN_SORTED_BAM \$CLEAN_RAW_BAM

	# Convert to FASTQ
	samtools fastq \\
		-@ ${task.cpus} \\
		-1 \$R1_OUT \\
		-2 \$R2_OUT \\
		-s \$SINGLETONS_OUT \\
		-0 /dev/null \$CLEAN_SORTED_BAM

	# Clean up intermediates
	rm \$CONT_BAM \$CONT_BAM.bai \$CLEAN_RAW_BAM \$CLEAN_SORTED_BAM
	"""
}


