#!/usr/bin/env nextflow

process shortAssembly {

    label "megahit"

    tag "sr-metagenome-assembly-${pop_id}"

    publishDir "${params.res.metagenome}/02-megahit", mode: 'symlink', pattern: '*.{fa,fastg}'

    container params.images.ASSEMBLY

    input:
    tuple val(pop_id), path(r1), path(r2)

    output:
    tuple val(pop_id), path("${pop_id}_k55/${pop_id}.contigs.fa"), path("${pop_id}.contigs.fastg"), emit: short_metagenomes
    
    script:
    """
    echo "[INFO]        Assembly following reads with MEGAHIT for population: ${pop_id}"
    echo "[INFO]            R1: \$(basename ${r1})"
    echo "[INFO]            R2: \$(basename ${r2})"

    # Assembling the metagenome
    megahit \\
        --k-list 21,33,55 \\
        --num-cpu-threads ${task.cpus} \\
        --memory 0.5 \\
        --continue \\
        -1 ${r1} \\
        -2 ${r2} \\
        -o ${pop_id}_k55 \\
        --out-prefix ${pop_id}

    # Generate fastg file
    megahit_toolkit contig2fastg 55 ${pop_id}_k55/intermediate_contigs/k55.contigs.fa > ${pop_id}.contigs.fastg

    echo "\$(date) [FINISH]      Assembly complete for ${pop_id}"
    """
}