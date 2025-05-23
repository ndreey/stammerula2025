process VALIDATE_PE {

    label 'stats'
    tag "validate-${meta.sample}_${meta.lane}-${type}"

    container params.images.STATS

    input:
    tuple val(meta), path(read1), path(read2), val(type)

    output:
    path("*.validate"), emit: validate

    script:
    """
    biopet-validatefastq -i ${read1} -j ${read2} &> ${meta.sample}_${meta.lane}-${type}-validate.txt

    if grep -q "no errors found" ${meta.sample}_${meta.lane}-${type}-validate.txt; then
        echo "${meta.sample}_${meta.lane}-${type},PASSED" > ${meta.sample}_${meta.lane}-passed.validate
    else
        echo "${meta.sample}_${meta.lane}-${type},FAILED" > ${meta.sample}_${meta.lane}-failed.validate
    fi
    """
}



process MERGE_VALI_RES {

    label "stats"
    tag "merge-${id}-validate-csv"

    publishDir "./results/stats", mode: "copy"

    input:
    tuple path(validate_files), val(id)

    output:
    path("${id}-validate.csv"), emit: validate_csv

    script:
    """
    # Write header
    echo "sample,status" > ${id}-validate.csv

    # Append all validate lines
    cat ${validate_files} >> ${id}-validate.csv
    """
}
