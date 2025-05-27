process metaWRAPbinning {

    label "metaWRAP_binning"
    tag "metaWRAP-binning"

    publishDir "${params.res.binning}/06-metaWRAP-bins/${id}", mode: 'symlink', pattern: 'binning_results'
    publishDir "${params.res.binning}/logs", mode: 'symlink', pattern: '*.log'

    container params.images.metaWRAP

    input:
    tuple val(id), path(metagenome), path(read1), path(read2)

    output:
    path("binning_results"), emit: bin_dirs
    path("binning_results/metabat2_bins"), emit: metabat2_bins, optional: true
    path("binning_results/maxbin2_bins"), emit: maxbin2_bins, optional: true
    path("binning_results/concoct_bins"), emit: concoct_bins, optional: true
    path("*.log"), emit: logs, optional: true
    
    script:
    """
    echo "[INFO] Starting metaWRAP binning with:"
    echo "  Metagenome: ${metagenome}"
    echo "  R1 reads: ${read1}"
    echo "  R2 reads: ${read2}"

    # Create temporary uncompressed fastq files
    R1_TEMP=\$(basename ${read1} .gz)
    R2_TEMP=\$(basename ${read2} .gz)

    echo "[INFO] Decompressing reads..."
    zcat ${read1} > \$R1_TEMP
    zcat ${read2} > \$R2_TEMP

    echo "[INFO] Running metaWRAP binning..."
    metawrap binning \\
        -a ${metagenome} \\
        -o binning_results \\
        -t ${task.cpus} \\
        -m ${task.memory.toGiga()} \\
        -l 2500 \\
        --metabat2 \\
        --maxbin2 \\
        --concoct \\
        \$R1_TEMP \$R2_TEMP 2>&1 | tee metawrap_binning.log

    # Clean up temporary files
    rm \$R1_TEMP \$R2_TEMP

    echo "[FINISH] metaWRAP binning complete"
    echo "[INFO] Results saved in binning_results/"
    """
}