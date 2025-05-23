# stammerula2025
```mermaid
flowchart TB
    subgraph QC_PREPROCESSING
    subgraph take
    v0["short_reads"]
    v1["long_reads"]
    v2["comp_ref"]
    v3["comp_headers"]
    end
    v5([VALIDATE_PE_RAW])
    v7([MERGE_VALI_RES_RAW])
    v10([FASTQ_STATS_SR_RAW])
    v11([FASTQ_STATS_LR_RAW])
    v13([FASTQC_RAW])
    v15([MULTIQC_RAW])
    v17([FASTQC_CCS])
    v19([MULTIQC_CCS])
    v20([TRIM])
    v22([FASTQC_TRIM])
    v24([MULTIQC_TRIM])
    v26([MULTIQC_FASTP])
    v28([VALIDATE_PE_TRIM])
    v30([MERGE_VALI_RES_TRIM])
    v32([FASTQ_STATS_SR_TRIM])
    v33([BWA_INDEX_COMP_REF])
    v35([INDEX_MINIMAP2])
    v37([DECON_SR])
    v38([DECON_LR])
    v40([VALIDATE_PE_DECON])
    v42([MERGE_VALI_RES_DECON])
    v45([FASTQ_STATS_SR_DECON])
    v46([FASTQ_STATS_LR_DECON])
    v0 --> v5
    v5 --> v7
    v0 --> v10
    v1 --> v11
    v0 --> v13
    v13 --> v15
    v1 --> v17
    v17 --> v19
    v0 --> v20
    v20 --> v22
    v22 --> v24
    v20 --> v26
    v20 --> v28
    v28 --> v30
    v20 --> v32
    v2 --> v33
    v2 --> v35
    v33 --> v37
    v2 --> v37
    v3 --> v37
    v20 --> v37
    v1 --> v38
    v2 --> v38
    v3 --> v38
    v35 --> v38
    v37 --> v40
    v40 --> v42
    v37 --> v45
    v38 --> v46
    end
```
