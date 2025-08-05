process shortAssembly {

    label "megahit"
    tag "sr-metagenome-assembly-${pop_id}"

    publishDir "${params.res.metagenome}/02-megahit/${pop_id}", mode: 'symlink', pattern: '*.fastg'
    publishDir "${params.res.metagenome}/02-megahit/${pop_id}", mode: 'symlink', pattern: '*.contigs.fa'

    container params.images.ASSEMBLY

    input:
    tuple val(pop_id), path(r1), path(r2)

    output:
    tuple val(pop_id), path("${pop_id}.contigs.fa"), path("${pop_id}.contigs.fastg"), emit: short_metagenomes
    
    script:
    """
    echo "[INFO] Assembly following reads with MEGAHIT for population: ${pop_id}"
    echo "[INFO]     R1: \$(basename ${r1})"
    echo "[INFO]     R2: \$(basename ${r2})"

    # Assembling the metagenome
    megahit \\
        --k-list 21,33,55 \\
        --num-cpu-threads ${task.cpus} \\
        --memory 0.5 \\
        --continue \\
        -1 ${r1} \\
        -2 ${r2} \\
        -o ${pop_id} \\
        --out-prefix ${pop_id}

    # Copy contigs to work directory root for easier publishing
    cp ${pop_id}/${pop_id}.contigs.fa ${pop_id}.contigs.fa

    # Generate fastg file
    megahit_toolkit contig2fastg 55 ${pop_id}/intermediate_contigs/k55.contigs.fa > ${pop_id}.contigs.fastg

    echo "[FINISH] Assembly complete for ${pop_id}"
    """
}