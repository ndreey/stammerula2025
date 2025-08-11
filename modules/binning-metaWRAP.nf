#!/usr/bin/env nextflow

process metaWRAPbinning {

    label "metaWRAP"
    tag "metaWRAP-binning-${id}"

    //container params.images.metaWRAP

    input:
    tuple val(id), path(metagenome), path(read1), path(read2)

    output:
    tuple val(id), path("binning_results/concoct_bins"), 
    path("binning_results/maxbin2_bins"), path("binning_results/metabat2_bins"), 
    emit: bin_dirs, optional: true
    
    script:
    """
    # Load modules
    ml load PDCOLD/23.12
    ml load bioinfo-tools
    ml load CONCOCT/1.1.0
    ml load MaxBin/2.2.7   # Maxbin2
    ml load metabat/2.15   # MetaBat2
    ml load bwa/0.7.17
    ml load samtools/1.20
    ml load hmmer/3.4-cpeGNU-23.12
    ml load checkm/1.2.2-cpeGNU-23.12

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

    echo "[INFO] Handling metagenome file..."
    # Try to decompress, if it fails, just use the file as-is
    (zcat ${metagenome} > \$METAGENOME 2>/dev/null) || METAGENOME=${metagenome}

    echo "[INFO] Running metaWRAP binning..."
    metawrap binning \\
        -a \$METAGENOME \\
        -o binning_results \\
        -t ${task.cpus} \\
        -m 64 \\
        -l 2500 \\
        --metabat2 \\
        --maxbin2 \\
        --concoct \\
        \$R1_TEMP \$R2_TEMP

    # Clean up temporary files
    #rm \$R1_TEMP \$R2_TEMP

    echo "[FINISH] metaWRAP binning complete for ${id}"
    """
}