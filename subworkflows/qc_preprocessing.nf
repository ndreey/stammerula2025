#!/usr/bin/env nextflow

include { BWA_INDEX_COMP_REF }          from '../modules/stam-index-bwa.nf'
include { INDEX_MINIMAP2 }              from '../modules/stam-index-minimap2.nf'
include { FASTQC as FASTQC_RAW }        from '../modules/stam-fastqc.nf'
include { FASTQC as FASTQC_CCS }        from '../modules/stam-fastqc.nf'
include { FASTQC as FASTQC_TRIM }       from '../modules/stam-fastqc.nf'
include { MULTIQC as MULTIQC_RAW }      from '../modules/stam-multiqc.nf'
include { MULTIQC as MULTIQC_CCS }      from '../modules/stam-multiqc.nf'
include { MULTIQC as MULTIQC_TRIM }     from '../modules/stam-multiqc.nf'
include { MULTIQC as MULTIQC_FASTP }    from '../modules/stam-multiqc.nf'
include { TRIM }                        from '../modules/stam-trim.nf'
include { DECON_SR }                    from '../modules/stam-decon-sr.nf'

workflow QC_PREPROCESSING {

    take:
        short_reads
        long_reads
        comp_ref
        comp_headers

    main:
        ////////////////////////////////////////////////////////////////////////////
        // 1. Generate a MultiQC report of the FastQC reports of the raw SR reads
        ////////////////////////////////////////////////////////////////////////////

        short_reads
            .flatMap { meta, r1, r2 -> [ tuple(meta, r1), tuple(meta, r2) ] }
            .set { sr_raw_reads }

        FASTQC_RAW(sr_raw_reads)

        FASTQC_RAW.out.fastqc_files
            .collect()
            .ifEmpty([])
            .set { multiqc_input_raw }

        MULTIQC_RAW(multiqc_input_raw)

        ////////////////////////////////////////////////////////////////////////////
        // 1.1 Generate a MultiQC report of the FastQC reports of the raw CCS reads
        ////////////////////////////////////////////////////////////////////////////

        long_reads
            .map { meta, read -> tuple(meta, read) }
            .set { lr_reads }

        FASTQC_CCS(lr_reads)

        FASTQC_CCS.out.fastqc_files
            .collect()
            .ifEmpty([])
            .set { multiqc_input_ccs }

        MULTIQC_CCS(multiqc_input_ccs)

        ////////////////////////////////////////////////////////////////////////////
        // 3. Trim short reads and generate MultiQC of FastQC and fastp reports
        ////////////////////////////////////////////////////////////////////////////

        TRIM(short_reads)

        TRIM.out.trimmed_reads
            .flatMap { meta, r1_trim, r2_trim -> [ tuple(meta, r1_trim), tuple(meta, r2_trim) ] }
            .set { trimmed_reads }

        FASTQC_TRIM(trimmed_reads)

        FASTQC_TRIM.out.fastqc_files
            .collect()
            .ifEmpty([])
            .set { multiqc_input_trim }

        MULTIQC_TRIM(multiqc_input_trim)

        TRIM.out.fastp_reports
            .map { meta, html, json -> json }
            .collect()
            .set { multiqc_input_fastp }

        MULTIQC_FASTP(multiqc_input_fastp)

        ///////////////////////////////////////////////////////////////////////////
        // 6. Index competitive reference
        ///////////////////////////////////////////////////////////////////////////

        BWA_INDEX_COMP_REF(comp_ref)

        BWA_INDEX_COMP_REF.out.comp_ref_files
            .set { comp_ref_files_ch }

        ///////////////////////////////////////////////////////////////////////////
        // 7. Decontaminate trimmed short reads
        ///////////////////////////////////////////////////////////////////////////

        DECON_SR(
            TRIM.out.trimmed_reads,
            comp_ref_files_ch,
            comp_headers
        )

}