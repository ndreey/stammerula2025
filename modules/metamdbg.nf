#!/usr/bin/env nextflow

process longAssembly {

    label "metamdbg"

    tag "lr-metagenome-assembly"

    publishDir "${params.res.metagenome}/01-metamdbg", mode: 'symlink', pattern: 'contigs.fasta.gz'
    publishDir "${params.res.metagenome}/01-metamdbg", mode: 'symlink', pattern: '*.log'

    container params.images.ASSEMBLY

    input:
    path(long_reads)

    output:
    path("contigs.fasta.gz"), emit: long_metagenome
    
    script:
    """
    echo "[INFO]        Assembly following reads with metaMDBG"
    for read in ${long_reads}; do
        echo "[INFO]            \$(basename \$read)"
    done

    metaMDBG asm \\
        --out-dir . \\
        --in-hifi ${long_reads.join(' ')} \\
        --threads ${task.cpus}

    echo "[FINISH]      Assembly complete"
    """
}