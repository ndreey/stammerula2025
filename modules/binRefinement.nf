#!/usr/bin/env nextflow

process binRefinement {

    tag "$pop"

    publishDir "results/bin_refinement", mode: 'copy'

    container './metawrap_final.sif'

    cpus 6
    memory '64 GB'
    time '6h 30m'


    input:
        val pop
        path concoct_bins_dir
        path maxbin2_bins_dir
        path metabat2_bins_dir

    output:
        path "bin_refinement_c50_x10", emit: refined_bins

    script:
    """
    ls /db/checkm-db
    echo "=== DATA_CONFIG contents ==="
    cat /usr/local/lib/python2.7/site-packages/checkm/DATA_CONFIG || echo "DATA_CONFIG not found"


    metawrap bin_refinement \\
        -o bin_refinement_c50_x10 \\
        -t ${task.cpus} \\
        -m 64 \\
        -A ${concoct_bins_dir} \\
        -B ${maxbin2_bins_dir} \\
        -C ${metabat2_bins_dir} \\
        -c 50 \\
        -x 10
    """

}




