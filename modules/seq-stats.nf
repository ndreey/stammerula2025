process FASTQ_STATS {

    label 'stats'
    tag "${id}-seqkit-stats"

    publishDir 'results/stats', mode: 'copy'

    container params.images.STATS

    input:
    tuple path(fastq_files), val(id)

    output:
    path("${id}-seq-stats.tsv"), emit: seq_stats_csv

    script:
    """
    mkdir -p reads

    # Copy all FASTQ files to reads/ for consistent naming
    cp ${fastq_files.join(' ')} reads/

    # Run seqkit stats on all of them
    seqkit stats \\
        --threads ${task.cpus} \\
        --tabular \\
        --basename \\
        reads/* > ${id}-seq-stats.tsv
    """
}
