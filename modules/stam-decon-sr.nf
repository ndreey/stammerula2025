#!/usr/bin/env nextflow

process DECON_SR {

    label "decon"

    tag "${meta.sample}_${meta.lane}"

    publishDir "${params.res.decon}/clean-reads", mode: 'symlink', pattern: '*_R{1,2}-clean.fq.gz'

    container params.images.ALIGN

    input:
    tuple val(meta), path(read1), path(read2)
	path(index_files)
	path(comp_ref)
    path(comp_headers)

    output:
    tuple val(meta),
        path("${meta.sample}_${meta.lane}_R1-clean.fq.gz"),
        path("${meta.sample}_${meta.lane}_R2-clean.fq.gz"),
        emit: decon_sr_reads

    script:
    """
	echo "[INFO]		Defining inputs"
    CONT_BAM="${meta.sample}_${meta.lane}.comp.sorted.bam"
    CONT_TXT="${meta.sample}_${meta.lane}-comp-reads.txt"
    CLEAN_RAW_BAM="${meta.sample}_${meta.lane}-clean.bam"
    CLEAN_SORTED_BAM="${meta.sample}_${meta.lane}-clean.sorted.bam"
    R1_OUT="${meta.sample}_${meta.lane}_R1-clean.fq.gz"
    R2_OUT="${meta.sample}_${meta.lane}_R2-clean.fq.gz"
    SINGLETONS_OUT="${meta.sample}_${meta.lane}_singletons.fq.gz"

	echo "[INFO]		Align against competetive reference"
    bwa mem \\
        -R "@RG\\tID:${meta.sample}_${meta.lane}\\tSM:${meta.sample}_${meta.lane}\\tPL:ILLUMINA" \\
        -t ${task.cpus} ${comp_ref} ${read1} ${read2} | \\
        samtools view -h -b -@ ${task.cpus} | \\
        samtools sort -@ ${task.cpus} --write-index -o \$CONT_BAM -

	echo "[INFO]		Grep the reads aligning to comp ref"
    samtools view -@ ${task.cpus} -f 3 -F 12 -q 20 \$CONT_BAM \$(cat ${comp_headers}) | \\
        awk '{print \$1}' | sort | uniq > \$CONT_TXT

	echo "[INFO]		Remove the reads that mapped to comp ref"
    samtools view -h -@ ${task.cpus} \$CONT_BAM | \\
        grep -F -v -f \$CONT_TXT | \\
        samtools view -h -@ ${task.cpus} -b -o \$CLEAN_RAW_BAM -

	echo "[INFO]		Sort the clean bam file"
    samtools sort -n -@ ${task.cpus} -o \$CLEAN_SORTED_BAM \$CLEAN_RAW_BAM

	echo "[INFO]		Write the read pairs"
    samtools fastq \\
        -@ ${task.cpus} \\
        -1 \$R1_OUT \\
        -2 \$R2_OUT \\
        -s \$SINGLETONS_OUT \\
        -0 /dev/null \$CLEAN_SORTED_BAM

	echo "[INFO]		Remove the temporary files"
    rm \$CONT_BAM \$CONT_BAM.csi \$CLEAN_RAW_BAM \$CLEAN_SORTED_BAM
    """
}


