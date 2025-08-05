#!/usr/bin/env nextflow

process BAKTA {

    label "bakta"
    tag "bakta-${pop}"

    publishDir "${params.res.binQuality}/${pop}/bakta", mode: 'symlink'

    container params.images.bakta

    input:
    tuple val(pop), path(refined_bins_dir)

    output:
    tuple val(pop), path("bakta_output"), emit: bakta_results

    script:
    """
    export MPLCONFIGDIR=./matplotlib_config

    # Run Bakta annotation on each bin individually
    for bin in ${refined_bins_dir}/metawrap_50_10_bins/*.fa; do
        bin_name=\$(basename \$bin .fa)
        echo "[INFO] Annotating bin: \$bin_name"
        
        # Create individual output directory for this bin
        mkdir -p bakta_output/\${bin_name}
        
        bakta \\
            --db /bakta_db \\
            --output bakta_output/\${bin_name} \\
            --prefix \${bin_name} \\
            --threads ${task.cpus} \\
            --keep-contig-headers \\
            --verbose \\
            --force \\
            \$bin
    done
    
    echo "[INFO] Bakta annotation completed for \$(ls ${refined_bins_dir}/metawrap_50_10_bins/*.fa | wc -l) bins"
    """
}
