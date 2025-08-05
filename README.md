
# stammerula2025
[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62.svg)](https://www.nextflow.io/) [![run with conda](https://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
 
## Introduction
**stammerula2025** is a  metagenomics analysis workflow designed for processing both short-read (Illumina) and long-read (PacBio HiFi) sequencing data. This pipeline performs quality control, decontamination, assembly, and binning to extract high-quality metagenome-assembled genomes (MAGs) from metagenomic samples.

## Pipeline Overview
The pipeline consists of several key stages:

1. **Quality Control & Trimming**  - Verifies and validates after each step.
2. **Decontamination** - Competitive mapping
3.  **Assembly** - Hybrid assembly using both short and long reads
4. **Binning** - Metagenomic binning and bin refinement
5. **MAG Assessment** - Annotation, taxonomic classification and MAG quality.

## Pipeline Architecture

```mermaid
flowchart TB
    subgraph "Input Data"
        SR[Short Reads<br/>Illumina]
        LR[Long Reads<br/>PacBio HiFi]
        REF[Competitive Reference<br/>Contamination DB]
    end
    
    subgraph "Quality Control & Preprocessing"
        QC1[FastQC Raw]
        TRIM[Fastp Trimming]
        QC2[FastQC Trimmed]
        DECON_SR[Decontamination SR]
        DECON_LR[Decontamination LR]
    end
    
    subgraph "Read Merging"
        MERGE_SAMPLE[Merge by Sample]
        MERGE_POP[Merge by Population]
    end
    
    subgraph "Assembly"
        ASM_SHORT[MEGAHIT<br/>Short Read Assembly]
        ASM_LONG[metaMDBG<br/>Long Read Assembly]
    end
    
    subgraph "Binning & Refinement"
        BIN[metaWRAP Binning<br/>CONCOCT + MaxBin2 + MetaBAT2]
        REFINE[Bin Refinement<br/>metaWRAP]
    end
    
    SR --> QC1
    LR --> QC1
    SR --> TRIM --> QC2
    TRIM --> DECON_SR
    LR --> DECON_LR
    DECON_SR --> MERGE_SAMPLE
    DECON_SR --> MERGE_POP
    MERGE_POP --> ASM_SHORT
    DECON_LR --> ASM_LONG
    ASM_LONG --> BIN
    MERGE_POP --> BIN
    BIN --> REFINE
```

  

## Quick Start

1. Install [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=23.04.0`)
2. Install apptainer
3. Clone the repository:

```bash
   git clone https://github.com/ndreey/stammerula2025.git
   cd stammerula2025
   ```

4. Prepare your metadata files (see [Input](#input) section)

5. Run the pipeline:

```bash
   nextflow run main.nf -params-file stam-params.yml -profile slurm
```

  
## Input Requirements

### 1. Short-Read Metadata (`metadata.sr`)
CSV file with columns:
- `POP`: Population identifier
- `HP`: Host plant
- `REG`: Region
- `regHP`: Region-host combination
- `SAMPLE`: Sample identifier
- `LANE`: Sequencing lane
- `READ1`: Path to R1 FASTQ file
- `READ2`: Path to R2 FASTQ file

### 2. Long-Read Metadata (`metadata.lr`)
CSV file with columns:
- `POP`: Population identifier
- `SAMPLE`: Sample identifier
- `CELL`: SMRT cell identifier
- `READ`: Path to HiFi FASTQ file

### 3. Competitive Reference
- `comp_ref_dir`: Directory containing reference genome
- `comp_ref_fasta`: Reference FASTA file
- `comp_headers`: File with reference sequence headers


## Parameters
Key parameters can be configured in `stam-params.yml`:

### Input/Output
- `metadata.sr`: Path to short-read metadata CSV
- `metadata.lr`: Path to long-read metadata CSV
- `references.comp.dir`: Competitive reference directory
- `references.comp.fasta`: Comp. reference FASTA file
- `references.comp.headers`: Comp. reference headers file
  
### Quality Control
- `trim.avg_qual`: Average quality threshold (default: 20)
- `trim.len_req`: Minimum length required (default: 50)

## Output

The pipeline generates several output directories:

```
results/
├── 00-QC/                          # Quality control reports
│   ├── fastqc-raw/                 # Raw read FastQC
│   ├── fastqc-trim/                # Trimmed read FastQC
│   ├── multiqc-raw/                # Raw read MultiQC
│   └── multiqc-trim/               # Trimmed read MultiQC
├── 01-trimmed/                     # Trimmed reads
├── 02-decontamination/             # Decontaminated reads
│   ├── clean-reads/                # Short reads
│   └── clean-reads-lr/             # Long reads
├── 03-sample-merged-sr/            # Sample-merged short reads
├── 04-pop-merged-sr/               # Population-merged short reads
├── 05-metagenomes/                 # Assembled metagenomes
│   ├── 01-metamdbg/                # Long-read assemblies
│   └── 02-megahit/                 # Short-read assemblies
├── 06-metaWRAP-refined-bins/       # Initial and refined bins
└── 07-bin-quality-assessment/      # Output to evaluate MAG quality.
```


  

## Resource Requirements

 ## Container Support

The pipeline uses Wave containers for reproducibility. Containers are automatically pulled when using Apptainer or other supported container engines.


  

## Citation
If you use stammerula2025 for your analysis, please cite:

> **stammerula2025: fancy title**
> *Author et al.* (2025)

And following programs that made this pipeline possible:

| Tool               | Version | Link |
| ------------------ | ------- | ---- |
| fastp              | 0.23.4  |      |
| Kraken2            | 2.1.2   |      |
| BWA-MEM            | 0.7.17  |      |
| BEDTools           | 2.31.1  |      |
| Minimap2           | 2.26    |      |
| SPAdes             | 3.15.5  |      |
| metaSPAdes         | 3.15.5  |      |
| hybridSPAdes       | 3.15.5  |      |
| Anvio              | 8.0     |      |
| Bowtie2            | tba     |      |
| Prodigal           | 2.6.3   |      |
| metaWRAP           | 1.3.2   |      |
| CONCOCT            | 1.0.0   |      |
| MaxBin2            | 2.2.7   |      |
| MetaBAT2           | 2.15    |      |
| CheckM             | 1.0.18  |      |
| CheckM2            | 1.0.1   |      |
| BUSCO              | 5.5.0   |      |
| GTDB-Tk            | 2.4.0   |      |
| Bakta              | 1.9.3   |      |
| BLAST+             | 2.15.0  |      |
| R script dotPlotly | N/A     |      |

## Support
For questions and support:
- Open an issue on [GitHub](https://github.com/ndreey/stammerula2025/issues)
- Check the [documentation](https://github.com/ndreey/stammerula2025)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---


*Pipeline developed by André Bourbonnais (ndreey) for Master Thesis research*