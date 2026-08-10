# Rescuing Orphan Bioinformatics Workflows results

This repository contains the Jupyter notebooks used for the analyses, figure generation, and selected results associated with the manuscript: 

**From Abandoned Scripts to FAIR Community Pipelines: Rescuing Orphan Bioinformatics Workflows with nf-core — Lessons from Light-Sheet Fluorescence Microscopy**

DOI: https://doi.org/10.64898/2026.07.29.741447

---
# Reproducing the Manuscript Results
The workflow consists of two stages:

1. Running the benchmark and scaling experiments using the archived NuMorph benchmarking repository.

2. Analyzing the generated results using the notebooks provided in this repository.

The raw benchmark and scaling outputs associated with this study are currently being prepared for deposition in a public repository. The location and persistent identifier will be added upon completion.

---

# Repository Structure

## resource_usage 
This directory contains the notebooks, figures, and processed results used for the resource usage and scaling analyses.
### figures 
- `Figure 6` (PNG and SVG)
- `Figure 7` (PNG and SVG)
### results
Aggregated results for the resource usage benchmark and scaling experiments.
- `screen_output.txt`: Command-line output generated during the benchmark runs. 
- `benchmark-summary_stats.json`: Summary statistics generated from the benchmark experiment. 
- `scaling_results.csv`: Aggregated results from the scaling experiment.

### Analysis notebook
- `resource_and_scaling_results.ipynb`: Notebook used to aggregate raw benchmark and scaling data and generate the corresponding manuscript figures.
---

## functional_equivalence_testing 
This directory contains analyses evaluating the functional equivalence of NuMorph and nf-core/lsmquant.
### figures
- `Figure 4`: (PNG and SVG)
- `Figure 5`: (PNG and SVG)
- `Figure S1`: (PNG and SVG)

### results
Contains mean squared error (MSE) calculations used for output comparisons.
#### Full Mouse Brain Dataset
- `mse_brn2_lsmquant_numorph.csv`: MSE values calculated per z-plane for the BRN2 channel.
- `mse_ctip2_lsmquant_numorph.csv`: MSE values calculated per z-plane for the CTIP2 channel.
- `mse_topro_lsmquant_numorph.csv`: MSE values calculated per z-plane for the TO-PRO channel.  

#### Benchmark Dataset

- `mse_matrix_C1.csv`: Pairwise MSE values calculated for all benchmark replicates for channel C1 (CTIP2).
- `mse_matrix_C2.csv`:Pairwise MSE values calculated for all benchmark replicates for channel C2 (TO-PRO).
---

# Setup

## Prerequisites
Create a Conda environment using the provided environment file:

```bash
conda env create -f environment.yml
conda activate orphan-bioinformatics-workflows 
```
Download the benchmark results archive from Zenodo: 

# Functional Equivalence Analysis 

Open the notebook used for output comparison and update the following paths. 

## Using Raw Benchmark Results
Update the variables in Cell 4:
- matlab_dir = path/to/results/performance_benchmark/matlab 
- nextflow_dir = path/to/results/performance_benchmark/nextflow
Run the notebook from the beginning.

## Using the Provided Processed Results
Run Cells 1-3 and continue execution from Cell 12.
For image visualization in Cell 13, update the image paths accordingly, for example:
-  path/to/results/performance_benchmark/matlab/replicate_08/stitched/sample08_0009_C2_ctip2_stitched.tif
Update all displayed image paths as necessary.

## Reproducing Figure S1
Start execution from:
```text
Read MSE per channel per z-plane from file
```
Then execute the subsequent cells to generate Figure S1.
---

# Resource Usage Analysis
Open the notebook resource_and_scaling_results.

## Using Raw Benchmark Results
Update Cell 1:
```text
res_base_path = path/to/results/performance_benchmark
```
Run the notebook from Cell 2 onward to regenerate the benchmark summary tables and figures from the raw outputs.

## Using the Provided Processed Results
Start execution from:
```text
Load benchmark data
```
This will load the precomputed benchmark dataframe included in the repository.
---

# Scaling results
Open:
```text
resource_and_scaling_results.ipynb
```
## Using Raw Scaling Results
Update the following variables:
- lsmquant_scaling_base_path = /path/to/results/performance_benchmark/scaling/nextflow
- numorph_scaling_base_path = /path/to/results/performance_benchmark/scaling/
Run the notebook sections used for aggregating scaling results.
## Using the Provided Processed Results
Start execution from:
```text
Manuscript Figure 7
```
This section loads the processed scaling data and reproduces the scaling analysis figures.
