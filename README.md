
# stammerula2025
[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62.svg)](https://www.nextflow.io/) [![run with conda](https://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
 
## Introduction
**stammerula2025** is a  metagenomics analysis workflow designed for processing both short-read (Illumina) and long-read (PacBio HiFi) sequencing data. This pipeline performs quality control, decontamination, assembly, and binning to extract high-quality metagenome-assembled genomes (MAGs) from metagenomic samples.

## Pipeline Overview
The pipeline consists of several key stages:

1. **Quality Control & Trimming**  - Verifies and validates after each step.
2. **Decontamination** - Competitive mapping
3.  **Assembly** - Long and short read assembly
4. **Binning** - Metagenomic binning and bin refinement
5. **MAG Assessment** - Annotation, taxonomic classification and MAG quality.

## Pipeline Workflow

![workflow](https://github.com/ndreey/stammerula2025/blob/main/doc/Untitled%20diagram%20_%20Mermaid%20Chart-2025-08-28-153745.png?raw=true)



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

```
#########################################################################
########################## Singularity Images ###########################
#########################################################################
# Images are created through seqera (https://seqera.io/)
# QC: Initial read processing and quality control (created 2025-05-15)
#   channels:
#   - conda-forge
#   - bioconda
#   dependencies:
#   - bioconda::bbmap=39.00
#   - bioconda::bwa=0.7.19
#   - bioconda::fastp=0.24.1
#   - bioconda::fastqc=0.12.1
#   - bioconda::minimap2=2.29
#   - bioconda::multiqc=1.28
#   - bioconda::picard=3.4.0
#   - bioconda::samtools=1.20
#   - bioconda::seqkit=2.10.0
#   - conda-forge::pigz=2.8
#
# ALIGN: Aligners and parse tools (created 2025-05-22)
#   channels:
#   - conda-forge
#   - bioconda
#   dependencies:
#   - bioconda::bedtools=2.31.1
#   - bioconda::bwa=0.7.19
#   - bioconda::minimap2=2.29
#   - bioconda::picard=3.4.0
#   - bioconda::samtools=1.20
#   - bioconda::seqkit=2.10.0
#   - conda-forge::pigz=2.8
#
# STATS: Sequence statistics programs (created 2025-05-22)
#   channels:
#   - conda-forge
#   - bioconda
#   dependencies:
#   - bioconda::bbmap=39.00
#   - bioconda::biopet-validatefastq=0.1.1
#   - bioconda::seqkit=2.10.0
#
# ASSEMBLY: Metagenome assembler for both short and long reads (created 2025-05-26)
#   channels:
#   - conda-forge
#   - bioconda
#   dependencies:
#   - bioconda::megahit=1.2.9
#   - bioconda::metamdbg=1.1
#
# metaWRAP: Wrapping program for metagenomic analysis (created 2025-05-26)
# channels:
# - conda-forge
# - bioconda
# dependencies:
# - bioconda::metawrap=1.1.0
#
# BUSCO: Completeness and contamination (created 2025-07-10)
# channels:
# - conda-forge
# - bioconda
# dependencies:
# - bioconda::busco=6.0.0
#
# GTDB-Tk: Taxonomic classifier (created 2025-05-14)
# channels:
# - conda-forge
# - bioconda
# dependencies:
# - bioconda::gtdbtk=2.4.1
#
# bakta: Prokaryotic annotater (created 2025-08-04)
# channels:
# - conda-forge
# - bioconda
# dependencies:
# - bioconda::bakta=1.11.3
#
# checkm2: Completeness and contamination (created 2025-03-14)
# channels:
# - conda-forge
# - bioconda
# dependencies:
# - bioconda::checkm2=1.1.0
#########################################################################
```

## Support
For questions and support:
- Open an issue on [GitHub](https://github.com/ndreey/stammerula2025/issues)
- Check the [documentation](https://github.com/ndreey/stammerula2025)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---


*Pipeline developed by André Bourbonnais (ndreey) for Master Thesis research*
