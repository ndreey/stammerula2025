#!/usr/bin/env nextflow

process setupCheckM2 {

    label "stats"

    tag "build-checkm2-db"

    publishDir "db/", mode: 'symlink', "checkm2-db/"

    container params.images.metaWRAP

    input:
    path(long_reads)

    output:
    path("checkm2-db/"), emit: checkmdb
    
    script:
    """
    echo "[INFO]        Download the db"
    checkm2 database --download --path checkm2-db

    echo "[FINISH]      CheckM2 setup complete"
    """
}