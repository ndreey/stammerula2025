#!/usr/bin/env nextflow

process BUSCO {

    label "busco"
    tag "busco-${pop}"

    publishDir "${params.res.binQuality}/${pop}", mode: 'symlink'

    container params.images.BUSCO

    input:
    tuple val(pop), path(refined_bins_dir)

    output:
    tuple val(pop), path("busco_output"), emit: busco_results

    script:
    """
    mkdir -p busco_output
    # Run BUSCO directly on bins in their original location
    for bin in ${refined_bins_dir}/metawrap_50_10_bins/*.fa; do
        bin_name=\$(basename \$bin .fa)
        echo "[INFO] Processing bin: \$bin_name"
        
        busco \\
            --in \$bin \\
            --out \${bin_name}_busco \\
            --mode genome \\
            --lineage_dataset ${params.BUSCO.lineage_db} \\
            --cpu ${task.cpus}
            
        # Move results to output directory
        mv \${bin_name}_busco busco_output/
    done
    
    echo "[INFO] BUSCO analysis completed for \$(ls ${refined_bins_dir}/metawrap_50_10_bins/*.fa | wc -l) bins"
    """
}
