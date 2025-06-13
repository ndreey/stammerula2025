#!/usr/bin/env nextflow

// Trimming and Decontamination modules
include { TRIM }                                        from '../modules/trim.nf'
include { BWA_INDEX_COMP_REF }                          from '../modules/index-bwa.nf'
include { INDEX_MINIMAP2 }                              from '../modules/index-minimap2.nf'
include { DECON_SR }                                    from '../modules/decon-sr.nf'
include { DECON_LR }                                    from '../modules/decon-lr.nf'

workflow READ_PROCESSING {

    take:
        short_reads         // [meta, r1, r2] - raw short reads
        long_reads          // [meta, read] - raw long reads
        comp_ref            // competitive reference fasta
        comp_headers        // competitive reference headers

    main:

        ///////////////////////////////////////////////////////////////////////////
        // 1. Trim short reads
        ///////////////////////////////////////////////////////////////////////////

        TRIM(short_reads)

        ///////////////////////////////////////////////////////////////////////////
        // 2. Index competitive reference for both short and long reads
        ///////////////////////////////////////////////////////////////////////////

        // Generate BWA index for short reads
        BWA_INDEX_COMP_REF(comp_ref)

        // Convert the output to a value channel using modern syntax
        comp_idx_ch = BWA_INDEX_COMP_REF.out.comp_idx.collect()
        
        // Generate minimap2 index for long reads
        INDEX_MINIMAP2(comp_ref)

        comp_mmi_ch = INDEX_MINIMAP2.out.comp_mmi.first()

        ///////////////////////////////////////////////////////////////////////////
        // 3. Decontaminate reads
        ///////////////////////////////////////////////////////////////////////////

        // Decontaminate trimmed short reads
        DECON_SR(
            TRIM.out.trimmed_reads,
            comp_idx_ch,
            comp_ref,
            comp_headers
        )

        // Decontaminate long reads
        DECON_LR(
            long_reads,
            comp_mmi_ch,
            comp_ref,
            comp_headers
        )

    emit:
        trimmed_reads = TRIM.out.trimmed_reads
        fastp_reports = TRIM.out.fastp_reports
        decon_sr_reads = DECON_SR.out.decon_sr_reads
        decon_lr_reads = DECON_LR.out.decon_lr_reads
        comp_idx = comp_idx_ch
        comp_mmi = comp_mmi_ch
}