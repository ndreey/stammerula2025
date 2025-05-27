#!/usr/bin/env nextflow

process setupCheckM {

    label "stats"

    tag "build-checkm-db"

    publishDir "db/", mode: 'symlink', "checkm-db/"

    container params.images.metaWRAP

    input:
    path(long_reads)

    output:
    path("checkm-db/"), emit: checkmdb
    
    script:
    """
    echo "[INFO]        Download the db"
    wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz
    
    echo "[INFO]        Decompress the .tar.gz"
    mkdir checkm-db
    tar -xvzf checkm_data_2015_01_16.tar.gz -C checkm-db

    echo "[FINISH]      CheckM setup complete"
    """
}