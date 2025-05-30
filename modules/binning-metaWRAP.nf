#!/usr/bin/env nextflow

process metaWRAPbinning {

    label "metaWRAP"
    tag "metaWRAP-binning-${id}"

    publishDir "${params.res.binning}/${id}", 
    mode: 'symlink', pattern: 'binning_results'

    container params.images.metaWRAP

    input:
    tuple val(id), path(metagenome), path(read1), path(read2)

    output:
    tuple val(id), path("binning_results/concoct_bins"), 
    path("binning_results/maxbin2_bins"), path("binning_results/metabat2_bins"), 
    emit: bin_dirs, optional: true
    
    script:
    """
    echo "[INFO] Starting metaWRAP binning for ${id} with:"
    echo "  Metagenome: ${metagenome}"
    echo "  R1 reads: ${read1}"
    echo "  R2 reads: ${read2}"

    # Create temporary uncompressed fastq files
    R1_TEMP="\$(basename ${read1} _R1.fq.gz)_1.fastq"
    R2_TEMP="\$(basename ${read2} _R2.fq.gz)_2.fastq"
    METAGENOME=metagenome.fa

    echo "metaWRAP friendly reads: \$R1_TEMP \$R2_TEMP"

    echo "[INFO] Decompressing reads..."
    zcat ${read1} > \$R1_TEMP
    zcat ${read2} > \$R2_TEMP

    echo "Decompressing metagenome to metaWRAP friendly format:"
    zcat ${metagenome} > \$METAGENOME

    echo "[INFO] Running metaWRAP binning..."
    metawrap binning \\
        -a \$METAGENOME \\
        -o binning_results \\
        -t ${task.cpus} \\
        -m 64 \\
        -l 2500 \\
        --metabat2 \\
        --concoct \\
        \$R1_TEMP \$R2_TEMP

    # Clean up temporary files
    #rm \$R1_TEMP \$R2_TEMP

    echo "[FINISH] metaWRAP binning complete for ${id}"
    """
}