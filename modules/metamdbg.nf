#!/usr/bin/env nextflow

process longAssembly {

    label "metamdbg"

    tag "metamdbg-${pop}-${sample}"

    publishDir "${params.res.metagenome}/01-metamdbg", mode: 'symlink', pattern: '*.contigs.fa.gz'

    container params.images.ASSEMBLY

    input:
    tuple val(pop), val(sample), path(long_reads)

    output:
    tuple val(pop), val(sample), path("${pop}-${sample}.contigs.fa.gz"),
    emit: long_metagenome
    
    script:
    """
    echo "[INFO]        Long read assembly with metaMDBG for ${pop}-${sample}"
    for read in ${long_reads}; do
        echo "[INFO]            \$(basename \$read)"
    done

    metaMDBG asm \\
        --out-dir . \\
        --in-hifi ${long_reads.join(' ')} \\
        --threads ${task.cpus}
   
    mv contigs.fasta.gz ${pop}-${sample}.contigs.fa.gz
    
    echo "[FINISH]      Assembly complete for ${pop}-${sample}"
    """
}