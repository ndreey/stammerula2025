#!/usr/bin/env nextflow

// Validate pair-end fastq files
include { VALIDATE_PE as VALIDATE_PE_RAW }              from '../modules/validate-fq.nf'
include { MERGE_VALI_RES as MERGE_VALI_RES_RAW }        from '../modules/validate-fq.nf'
include { VALIDATE_PE as VALIDATE_PE_TRIM }             from '../modules/validate-fq.nf'
include { MERGE_VALI_RES as MERGE_VALI_RES_TRIM }       from '../modules/validate-fq.nf'
include { VALIDATE_PE as VALIDATE_PE_DECON }            from '../modules/validate-fq.nf'
include { MERGE_VALI_RES as MERGE_VALI_RES_DECON }      from '../modules/validate-fq.nf'

// Sequence statistics after each processing step
include {FASTQ_STATS as FASTQ_STATS_SR_RAW}            from '../modules/seq-stats.nf'
include {FASTQ_STATS as FASTQ_STATS_SR_TRIM}           from '../modules/seq-stats.nf'
include {FASTQ_STATS as FASTQ_STATS_SR_DECON}          from '../modules/seq-stats.nf'
include {FASTQ_STATS as FASTQ_STATS_LR_RAW}            from '../modules/seq-stats.nf'
include {FASTQ_STATS as FASTQ_STATS_LR_DECON}          from '../modules/seq-stats.nf'

// FastQC and MultiQC reports
include { FASTQC as FASTQC_RAW }                        from '../modules/fastqc.nf'
include { FASTQC as FASTQC_CCS }                        from '../modules/fastqc.nf'
include { FASTQC as FASTQC_TRIM }                       from '../modules/fastqc.nf'
include { MULTIQC as MULTIQC_RAW }                      from '../modules/multiqc.nf'
include { MULTIQC as MULTIQC_CCS }                      from '../modules/multiqc.nf'
include { MULTIQC as MULTIQC_TRIM }                     from '../modules/multiqc.nf'
include { MULTIQC as MULTIQC_FASTP }                    from '../modules/multiqc.nf'

// Trimming and Decontamination
include { TRIM }                                        from '../modules/trim.nf'
include { BWA_INDEX_COMP_REF }                          from '../modules/index-bwa.nf'
include { INDEX_MINIMAP2 }                              from '../modules/index-minimap2.nf'
include { DECON_SR }                                    from '../modules/decon-sr.nf'
include { DECON_LR }                                    from '../modules/decon-lr.nf'


workflow QC_PREPROCESSING {

    take:
        short_reads
        long_reads
        comp_ref
        comp_headers

    main:

        ////////////////////////////////////////////////////////////////////////////
        // 1. Validate and get stats of the reads
        ////////////////////////////////////////////////////////////////////////////

        // Check validation of pair-end reads
        short_reads
            .map { meta, r1, r2 -> tuple(r1, r2, "sr-raw") }
            .set { short_reads_raw }

        VALIDATE_PE_RAW(short_reads_raw)

        VALIDATE_PE_RAW.out.validate
            .collect()
            .map {files -> tuple(files, "sr-raw") }
            .set { raw_validate_results }

        MERGE_VALI_RES_RAW(raw_validate_results)

        // Get the stats of the reads
        short_reads
            .flatMap { meta, r1, r2 -> [r1, r2] }
            .collect()
            .map { files -> tuple(files, "sr-raw") }
            .set { raw_sr }
        
        long_reads
            .flatMap { meta, read -> [read] }
            .collect()
            .map { files -> tuple(files, "lr-raw") }
            .set { raw_lr }

        FASTQ_STATS_SR_RAW(raw_sr)

        FASTQ_STATS_LR_RAW(raw_lr)

        ////////////////////////////////////////////////////////////////////////////
        // 2. Generate a MultiQC report of the FastQC reports of the raw SR reads
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
        // 2.1 Generate a MultiQC report of the FastQC reports of the raw CCS reads
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

        ////////////////////////////////////////////////////////////////////////////
        // 4. Validate and get stats of the trimmed reads
        ////////////////////////////////////////////////////////////////////////////
        
        // Check validation of pair-end reads
        TRIM.out.trimmed_reads
            .map { meta, r1, r2 -> tuple(r1, r2, "sr-trim") }
            .set { short_reads_trim }

        VALIDATE_PE_TRIM(short_reads_trim)

        VALIDATE_PE_TRIM.out.validate
            .collect()
            .map {files -> tuple(files, "sr-trim") }
            .set { trim_validate_results }

        MERGE_VALI_RES_TRIM(trim_validate_results)

        // Get the stats of trim reads
        TRIM.out.trimmed_reads
            .flatMap { meta, r1, r2 -> [r1, r2] }
            .collect()
            .map { files -> tuple(files, "sr-trim") }
            .set { trim_sr }
        
        FASTQ_STATS_SR_TRIM(trim_sr)

        ///////////////////////////////////////////////////////////////////////////
        // 5. Index competitive reference
        ///////////////////////////////////////////////////////////////////////////

        // generate index files and create value channels
        BWA_INDEX_COMP_REF(comp_ref)

        // Convert the output to a value channel
        BWA_INDEX_COMP_REF.out.comp_idx
            .collect()
            .set { comp_idx_ch }
        
        INDEX_MINIMAP2(comp_ref)

        INDEX_MINIMAP2.out.comp_mmi
            .first()
            .set { comp_mmi_ch }


        ///////////////////////////////////////////////////////////////////////////
        // 6. Decontaminate trimmed short reads
        ///////////////////////////////////////////////////////////////////////////
        DECON_SR(
            TRIM.out.trimmed_reads,
            comp_idx_ch,
            comp_ref,
            comp_headers)

        DECON_LR(
            lr_reads,
            comp_mmi_ch,
            comp_ref,
            comp_headers
        )

        ////////////////////////////////////////////////////////////////////////////
        // 5. Validate and get stats of the decon reads
        ////////////////////////////////////////////////////////////////////////////
        DECON_SR.out.decon_sr_reads
            .map { meta, r1, r2 -> tuple(r1, r2, "sr-decon") }
            .set { short_reads_decon }

        VALIDATE_PE_DECON(short_reads_decon)

        VALIDATE_PE_DECON.out.validate
            .collect()
            .map {files -> tuple(files, "sr-decon") }
            .set { decon_validate_results }

        MERGE_VALI_RES_DECON(decon_validate_results)

                // Get the stats of trim reads
        DECON_SR.out.decon_sr_reads
            .flatMap { meta, r1, r2 -> [r1, r2] }
            .collect()
            .map { files -> tuple(files, "sr-decon") }
            .set { decon_sr }
        
        DECON_LR.out.decon_lr_reads
            .flatMap { meta, read -> [read] }
            .collect()
            .map { files -> tuple(files, "lr-decon") }
            .set { decon_lr }
        
        FASTQ_STATS_SR_DECON(decon_sr)
        FASTQ_STATS_LR_DECON(decon_lr)

        ////////////////////////////////////////////////////////////////////////////
        // 6. Emit the decontaminated reads (keep individual tuples for merging)
        ////////////////////////////////////////////////////////////////////////////

    emit:
        decon_sr_reads = DECON_SR.out.decon_sr_reads
        decon_lr_reads = DECON_LR.out.decon_lr_reads
}