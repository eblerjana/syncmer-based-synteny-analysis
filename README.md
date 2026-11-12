# Inversion Plots

Pipeline to create PAF files between pairs of FASTA sequences based on syncmer matches. Can be used to create synteny plots.

## Requirements
The pipeline relies on two external tools which are still under active development:

- `syng` (https://github.com/richarddurbin/syng)
- `syncmer-toolkit` (https://github.com/eblerjana/syncmer-toolkit/)


Currently, these tools need to be installed according to the respective instructions in the githubs and paths to executables need to be provided to the pipeline as explained below.

## How to set up

A config file needs to be provided in `config/config.yml`. The config file needs to contain the following fields:

```bash
# paths to executables
syncmer_toolkit: "/path/to/syncmer-toolkit"
syncmer_scripts: "/path/to/syncmer-toolkit/scripts"
syng: "/path/to/syng-main"

# name of the output folder
results: "results"

# sample sheet. TSV files with format: <sample> <path/to/assembly.fasta> <contig index> <interval> <contig length> <contig name>
sample_sheet: "/path/to/sample-sheet.tsv"

# define pairwise alignments to be produced
alignments:
     align1:
        - sample1
        - sample2
     align2:
        - sample2
        - sample3

# parameters for syng, currently set to default parameters.
window_len: 63
kmer_len: 8 

```


- `syncmer_toolkit`: needs to point to the binary of the syncmer-toolkit
- `syncmer_scripts`: folder where the scripts (https://github.com/eblerjana/syncmer-toolkit/tree/main/scripts) are located
- `syng`: needs to point to the binary of syng
- `results`: name of the output folder to be produced
- `sample_sheet`: TSV file specifying paths to FASTA files and contigs to be analyzed. The file needs to contain the following columns in that order (see `synteny-plots/sample-sheet.tsv` for an example):
    - name of the sample
    - path to FASTA assembly
    - index of the contig in the FASTA to be considered
    - interval (<start>-<end>) on relative to the contig to be considered
    - length of the contig to be considered
    - name of the contig to be considered
- `alignments`: defines which pairwise alignments to be computed. 
- `window_len`: window length parameter to be used for syng
- `kmer_len`: kmer length parameter to be used for syng

## How to run 
The pipeline can be run with snakemake, e.g. using:

`snakemake --use-conda`