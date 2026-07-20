# Rescuing Orphan Bioinformatics Workflows

This repository containes scripts and parts of the results for the paper ( to be submitted: From Abandoned Scripts to FAIR Community Pipelines: Rescuing Orphan Bioinformatics Workflows with nf-core — Lessons from Light-Sheet Fluorescence Microscopy)

The Repository ist structured as follows: 

resource_usage: 
- figures: 
    - `Figure 6`: as png and svg
    - `Figure 7`: as png and svg
- results: aggregated results for resource usage and batch processing
    - `screen_output.txt`: commandline output generated during the benchmark run 
    - `benchmark-summary_stats.json`: dataframe containing the summary statistics from the benchmark run 
    - `scaling_results.csv`: aggregated data obtained by the batch processing experimentf
- scripts: contains bash scripts for the benchmark run and scaling experiments
    - `benshmark.sh`: the script was used to run the benchmark experiments of executing nf-core/lsmquant and NuMorph each 30 times on the same sample automatically and in random order. 
    - `monitoring_script.sh`: the script is used to monitor NuMorphs resource usage during execution. It is based on the logic of how nextflow monitors processes to enable similar comparison of resources. 
    - `scaling.sh`: this script is used to run NuMorphs scaling experiment (processing multiple samples)

- `benchmark.config`: config file to allow nf-core/lsmquant as much resources as the process wants. The resource limits are set to the hardware limits.
- `resource_and_scalin_results.ipynb`: Jupyter notebook that was used to aggregate raw data and generate the figures and results for resource usage and scaling experiments.

functional_equivalence_testing: 
- figures:
    - `Figure 4`: as png and svg
    - `Figure 5`: as png and svg
    - `Figure S1`: as png and svg
- results: contains calculated MSE matrices for output comparisons
    - `mse_brn2_lsmquant_numorph.csv`: all MSE calculations per z-plane for the channel brn2 (full mouse brain dataset)
    - `mse_ctip2_lsmquant_numorph.csv`: all MSE calculations per z-plane for the channel ctip2 (full mouse brain dataset)
    - `mse_topro_lsmquant_numorph.csv`: all MSE calculations per z-plane for the channel topro (full mouse brain dataset)  
    - `mse_matrix_C1.csv`: all pairwise MSE calculations for each replicate of the benchmark experiment for channel 1 ctip2 (test dataset)
    - `mse_matrix_C2.csv`:all pairwise MSE calculations for each replicate of the benchmark experiment for channel 2 topro (test dataset)