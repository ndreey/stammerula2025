#!/usr/bin/env nextflow

process DECON_LR {

    label "decon"

    tag "${meta.sample}_${meta.lane}"

    publishDir "${params.res.decon}/clean-reads-lr", mode: 'symlink', pattern: '*-clean.fq.gz'

    container params.images.ALIGN

    input:
    tuple val(meta), path(read)
	path(index_files)
	path(comp_ref)
    path(comp_headers)

    output:
    tuple val(meta), path("*-clean.fq.gz"), emit: decon_lr_reads
    
    script:
    """

    echo "[INFO]		Define input and outputs"
    ID=${meta.sample}_${meta.lane}
    READ=${read}
    CONT_REF=${comp_ref}
    CONT_HEADERS=${comp_headers}
    CPU=${task.cpus}

    CONT_SAM=\${ID}.cont.sam
    CONT_BAM=\${ID}.cont.sorted.bam
    CONT_TXT=\${ID}-cont-reads.txt
    CLEAN_RAW_BAM=\${ID}-clean.bam
    CLEAN_SORTED_BAM=\${ID}-clean.sorted.bam
    READ_OUT=\${ID}-clean.fq

    echo "[INFO]		Align to competetive reference"
    minimap2 \\
        -t \$CPU \\
        -x map-hifi \\
        -a \\
        --split-prefix \${ID}-split \\
        \$CONT_REF \$READ > \$CONT_SAM

    samtools sort -@ \$CPU --write-index -o \$CONT_BAM \$CONT_SAM

    echo "[INFO]		Remove the SAM file: \$CONT_SAM"
    rm \$CONT_SAM

    echo "[INFO]		Extract the reads aligning to comp ref"
    samtools view -@ \$CPU -q 20 \$CONT_BAM \$(cat \$CONT_HEADERS) | \\
        awk '{print \$1}' | sort | uniq > \$CONT_TXT


    echo "[INFO]		Remove the reads that aligned to comp ref"
    samtools view -h -@ \$CPU \$CONT_BAM | \\
        grep -vf \$CONT_TXT | \\
        samtools view -h -@ \$CPU -b -o \$CLEAN_RAW_BAM -
    
    echo "[INFO]		Sort the clean bam file"
    samtools sort -n -@ \$CPU -o \$CLEAN_SORTED_BAM \$CLEAN_RAW_BAM

    echo "[INFO]		Write the reads to fastqc"
    bedtools bamtofastq -i \$CLEAN_SORTED_BAM -fq \$READ_OUT
    pigz -p \$CPU \$READ_OUT

    echo "[INFO]		Remove the temporary files"
    rm \$CONT_BAM \$CLEAN_RAW_BAM \$CLEAN_SORTED_BAM
    """
}