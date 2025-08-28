
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

## Pipeline Architecture
_pipeline v1.0 complete, flowchart, not so complete._
So here is tree structure of the results folder.

FLOWCHART IS IN PROGRESS

```bash
tree -L 3 -d results/
results/
├── 00-QC
│   ├── fastqc-ccs-raw
│   ├── fastqc-raw
│   ├── fastqc-trim
│   ├── multiqc-ccs-raw
│   │   └── multiqc_data -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/53/f5ec2b8cd48ca9ee3b62e18dc31ffa/multiqc_data
│   ├── multiqc-fastp
│   │   └── multiqc_data -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/59/a9baf910465dc80802ae25efc6b7e9/multiqc_data
│   ├── multiqc-raw
│   │   └── multiqc_data -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/84/989ba4135a6577f9f845efa9e80fb1/multiqc_data
│   └── multiqc-trim
│       └── multiqc_data -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/0e/febe5a05967fdaf68e383ac98bebfd/multiqc_data
├── 01-trimmed
├── 02-decontamination
│   ├── clean-reads
│   └── clean-reads-lr
├── 03-sample-merged-sr
├── 04-pop-merged-sr
├── 05-metagenomes
│   ├── 01-metamdbg
│   └── 02-megahit
│       ├── CHES
│       ├── CHFI
│       ├── CHSC
│       ├── CHSK
│       ├── CHST
│       ├── COES
│       ├── COGE
│       ├── COLI
│       ├── COSK
│       └── CPSC
├── 06-metaWRAP-refined-bins
│   ├── CHES
│   │   └── bin_refinement -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/cb/9412254cb51411ae9e369b4f072835/bin_refinement
│   ├── CHFI
│   │   └── bin_refinement -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/1a/09238cb6e507af42be811db9a51b83/bin_refinement
│   ├── CHSC
│   │   └── bin_refinement -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/f3/5359b69cf9b6b4df689d2d3216d730/bin_refinement
│   ├── CHSK
│   │   └── bin_refinement -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/1d/f535986895dc6aa6c1e3f6c48a9470/bin_refinement
│   ├── CHST
│   │   └── bin_refinement -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/9f/1855641477215bbeeb36702a1b9463/bin_refinement
│   ├── CHST-pt_042
│   │   └── bin_refinement -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/42/da6c56bbba54f5618a66a0027b3a96/bin_refinement
│   ├── COES
│   │   └── bin_refinement -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/aa/2dab68851ceea47137486bedd4d13c/bin_refinement
│   ├── COGE
│   │   └── bin_refinement -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/00/1ef78a22c2d512af44ea65701c113b/bin_refinement
│   ├── COLI
│   │   └── bin_refinement -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/e1/a5915aa9d71ef8df4e8b0dcb7d7343/bin_refinement
│   ├── COSK
│   │   └── bin_refinement -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/69/258706cebf8279196872a0742f7ddc/bin_refinement
│   └── CPSC
│       └── bin_refinement -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/f1/3da742cf7e64d6ce71814d87bd9268/bin_refinement
├── 07-bin-quality-assessment
│   ├── CHES
│   │   ├── bakta
│   │   ├── busco_output -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/f1/3fee789b1a861cb30b7b579678b715/busco_output
│   │   ├── checkm2
│   │   └── GTDB-Tk
│   ├── CHFI
│   │   ├── bakta
│   │   ├── busco_output -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/d9/1ef91681e906749505629dd3aea19f/busco_output
│   │   ├── checkm2
│   │   └── GTDB-Tk
│   ├── CHSC
│   │   ├── bakta
│   │   ├── busco_output -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/41/f42059ccd7517afa71613827e34402/busco_output
│   │   ├── checkm2
│   │   └── GTDB-Tk
│   ├── CHSK
│   │   ├── bakta
│   │   ├── busco_output -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/ee/4c37c5d552467fa6e965bc21171e72/busco_output
│   │   ├── checkm2
│   │   └── GTDB-Tk
│   ├── CHST
│   │   ├── bakta
│   │   ├── busco_output -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/93/67e403a61f7127d1096e128a7bdb53/busco_output
│   │   ├── checkm2
│   │   └── GTDB-Tk
│   ├── CHST-pt_042
│   │   ├── bakta
│   │   ├── busco_output -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/1a/833229ba0635658f879ded3faafa50/busco_output
│   │   ├── checkm2
│   │   └── GTDB-Tk
│   ├── COES
│   │   ├── bakta
│   │   ├── busco_output -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/e0/b51556ebe4ae7c5800b707db984e73/busco_output
│   │   ├── checkm2
│   │   └── GTDB-Tk
│   ├── COGE
│   │   ├── bakta
│   │   ├── busco_output -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/80/9f58aff5a7a430f879273d3bd84f73/busco_output
│   │   ├── checkm2
│   │   └── GTDB-Tk
│   ├── COLI
│   │   ├── bakta
│   │   ├── busco_output -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/72/391118d945d67d8f309749633b63b9/busco_output
│   │   ├── checkm2
│   │   └── GTDB-Tk
│   ├── COSK
│   │   ├── bakta
│   │   ├── busco_output -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/24/948cea903c1747263eab2306789d17/busco_output
│   │   ├── checkm2
│   │   └── GTDB-Tk
│   └── CPSC
│       ├── bakta
│       ├── busco_output -> /cfs/klemming/projects/supr/snic2020-6-222/Projects/Tconura/working/Andre/stammerula2025/work/9e/2e4a5687f9294f333b15ce2ffc55bf/busco_output
│       ├── checkm2
│       └── GTDB-Tk
└── stats

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
