#!/usr/bin/env nextflow

include { BWA_INDEX_CONT_REF }          from './modules/stam-index-bwa.nf'
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



workflow QC_PREPROCESSING {

    take:
        short_reads
        long_reads
        cont_ref
        cont_headers

    main:

        //
        // 1. FASTQC on raw short reads
        //
        short_reads
            .map { meta, r1, r2 -> [r1, r2] }
            .flatten()
            .set { sr_raw_reads }

        FASTQC_RAW(sr_raw_reads)

        FASTQC_RAW.out.fastqc_html
            .collect()
            .map { file("${params.res.qc}/fastqc-raw") }
            .set { fastqc_raw_dir }

        MULTIQC_RAW(fastqc_raw_dir)


        //
        // 2. FASTQC on raw long reads
        //
        long_reads
            .map { meta, read -> read }
            .set { lr_reads }

        FASTQC_CCS(lr_reads)

        FASTQC_CCS.out.fastqc_html
            .collect()
            .map { file("${params.res.qc}/fastqc-ccs-raw") }
            .set { fastqc_ccs_dir }

        MULTIQC_CCS(fastqc_ccs_dir)


        //
        // 3. Trim short reads
        //
        short_reads
            .map { meta, r1, r2 -> tuple(meta.sample, r1, r2) }
            .set { paired_reads_ch }

        TRIM(paired_reads_ch)

        TRIM.out.set { trimmed_output_ch }


        //
        // 4. FASTQC on trimmed reads
        //
        trimmed_output_ch
            .map { sample_id, r1, r2, html, json -> [r1, r2] }
            .flatten()
            .set { trimmed_reads_fastqc }

        FASTQC_TRIM(trimmed_reads_fastqc)

        FASTQC_TRIM.out.fastqc_html
            .collect()
            .map { file("${params.res.qc}/fastqc-trim") }
            .set { fastqc_trim_dir }

        MULTIQC_TRIM(fastqc_trim_dir)


        //
        // 5. MultiQC on FASTP reports
        //
        trimmed_output_ch
            .map { sample_id, r1, r2, html, json -> html.parent }
            .collect()
            .set { fastp_report_dir }

        MULTIQC_FASTP(fastp_report_dir)


        //
        // 6. BWA index (if missing)
        //
        def bwt_index = file("${cont_ref}.bwt")
        Channel
            .value(cont_ref)
            .if { !bwt_index.exists() }
            .set { cont_ref_ch }

        if (cont_ref_ch) {
            BWA_INDEX_CONT_REF(cont_ref_ch)
            BWA_INDEX_CONT_REF.out.cont_ref_index.set { cont_ref_index_ch }
        } else {
            cont_ref_index_ch = Channel.value(bwt_index)
        }


        //
        // 7. Decontaminate
        //
        trimmed_output_ch
            .map { sample_id, r1, r2, html, json -> tuple(sample_id, r1, r2) }
            .combine(cont_ref_index_ch)
            .set { decon_input_ch }

        DECON_SR(decon_input_ch)

    emit:
        decont_trimmed_reads = DECON_SR.out.cleaned_reads
        long_reads           = long_reads
        metadata             = trimmed_output_ch.map { sample_id, r1, r2, html, json -> sample_id }
}
