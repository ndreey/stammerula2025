#!/usr/bin/env nextflow

include { BWA_INDEX_CONT_REF }                   from './modules/stam-index-bwa.nf'
include { INDEX_MINIMAP2 }              from './modules/stam-index-minimap2.nf'
include { FASTQC as FASTQC_RAW }        from './modules/stam-fastqc.nf'
include { FASTQC as FASTQC_CCS }        from './modules/stam-fastqc.nf'
include { FASTQC as FASTQC_TRIM }       from './modules/stam-fastqc.nf'
include { MULTIQC as MULTIQC_RAW }      from './modules/stam-multiqc.nf'
include { MULTIQC as MULTIQC_CCS }      from './modules/stam-multiqc.nf'
include { MULTIQC as MULTIQC_TRIM }     from './modules/stam-multiqc.nf'
include { MULTIQC as MULTIQC_FASTP }    from './modules/stam-multiqc.nf'
include { TRIM }                        from './modules/stam-trim.nf'
include { DECON_SR }                    from './modules/stam-decon-sr.nf'




workflow {

    // Define paths
    def cont_ref_path = file(params.decon.cont_ref)
    def bwt_file_path = file("${params.decon.cont_ref}.bwt")

    // Only create the channel if index is missing
    if ( !bwt_file_path.exists() ) {
        Channel
            .fromPath(cont_ref_path)
            .set { cont_ref_ch }

        BWA_INDEX_CONT_REF(cont_ref_ch)
        BWA_INDEX_CONT_REF.out.cont_ref_index.set { cont_ref_index_ch }
    } else {
        log.info "BWA index exists for ${params.decon.cont_ref} — skipping BWA_INDEX_CONT_REF"
    }

    ////////////////////////////////////////////////////////////////////////////
    // 1. Generate a MultiQC report of the FastQC reports of the raw sr reads
    ////////////////////////////////////////////////////////////////////////////

    // Create a channel for the sr fastq files
    Channel
        .fromPath(params.fastqc_raw.input)
        .set { fastqc_input_ch }

    // Run the FASTQC process on the files
    FASTQC_RAW(fastqc_input_ch)

    // Wait for all FASTQC jobs to finish and collect them.
    FASTQC_RAW.out.fastqc_html
        .collect()
        .set { fastqc_raw_done_ch }
    
    // Pass the output directory path to MultiQC.
    fastqc_raw_done_ch
        .map { file("${params.res.qc}/fastqc-raw") }
        .set { fastqc_raw_dir }
    
    MULTIQC_RAW(fastqc_raw_dir)

    ////////////////////////////////////////////////////////////////////////////
    // 1.1 Generate a MultiQC report of the FastQC reports of the raw CCS reads
    ////////////////////////////////////////////////////////////////////////////

    Channel
        .fromPath(params.fastqc_ccs.input)
        .set { fastqc_ccs_input_ch }

    FASTQC_CCS(fastqc_ccs_input_ch)

    FASTQC_CCS.out.fastqc_html
        .collect()
        .map { file("${params.res.qc}/fastqc-ccs-raw") }
        .set { fastqc_ccs_dir }

    MULTIQC_CCS(fastqc_ccs_dir)

    ////////////////////////////////////////////////////////////////////////////
    // 2. Trim the Illumina paired-end short reads
    ////////////////////////////////////////////////////////////////////////////
    Channel
        .fromFilePairs(params.trim.input, flat: true)
        .set { paired_reads_ch }

    // Run the TRIM process on the sr pe reads.
    TRIM(paired_reads_ch)

    // Capture the full output from the TRIM process
    // [ sample_id, trimmed_r1, trimmed_r2, fastp_html, fastp_json ]
    TRIM.out
        .set { trimmed_output_ch }


    ////////////////////////////////////////////////////////////////////////////
    // 3. Generate a MultiQC report of the FASTQC reports on trimmed reads
    ////////////////////////////////////////////////////////////////////////////

    // Extract only the trimmed R1 and R2 reads
    trimmed_output_ch
        .map { sample_id, r1, r2, html, json -> [r1, r2] }
        .flatten()
        .set { trimmed_reads_ch }

    FASTQC_TRIM(trimmed_reads_ch)

    // Collect fastqc output
    FASTQC_TRIM.out.fastqc_html
        .collect()
        .map { file("${params.res.qc}/fastqc-trim") }
        .set { fastqc_trim_dir }

    MULTIQC_TRIM(fastqc_trim_dir)


    ////////////////////////////////////////////////////////////////////////////
    // 3.1 Generate a MultiQC report on fastp HTML reports
    ////////////////////////////////////////////////////////////////////////////

    //  Collect the fastp html files
    trimmed_output_ch
        .map { sample_id, r1, r2, html, json -> html.parent }
        .collect()
        .set { fastp_report_dir }

    MULTIQC_FASTP(fastp_report_dir)


    ////////////////////////////////////////////////////////////////////////////
    // 4. Decontaminate the sr trimmed reads
    ////////////////////////////////////////////////////////////////////////////

    trimmed_output_ch
	    .map { sample_id, r1, r2, html, json -> tuple(sample_id, r1, r2) }
	    .set { trimmed_reads_ch }

    // Join reads with index
    trimmed_reads_ch
        .combine(cont_ref_index_ch)
        .set { decon_input_ch }

    DECON_SR(decon_input_ch)

}

