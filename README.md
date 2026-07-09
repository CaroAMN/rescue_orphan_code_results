# Rescuing Orphan Bioinformatics Workflows

This repository containes scripts and parts of the results for the paper ( to be submitted: From Abandoned Scripts to FAIR Community Pipelines: Rescuing Orphan Bioinformatics Workflows with nf-core — Lessons from Light-Sheet Fluorescence Microscopy)

The Repository ist structured as follows: 

resource_usage: 
- Figures: Contains Figure 5 and Figure 7 as png
- results: 
    - `screen_output.txt` commandline output generated during the benchmark run 
    - `benchmark-summary_stats.json` Dataframe containing the summary statistics from the benchmark run 
- scripts: contains bash scripts for the benchmark run and scaling experiments
    - `benshmark.sh`: the script was used to run the benchmark experiments of executing nf-core/lsmquant and NuMorph each 30 times on the same sample automatically and in random order. 
    - `monitoring_script.sh`: the script is used to monitor NuMorphs resource usage during execution. It is based on the logic of how nextflow monitors processes to enable similar comparison of resources. 
    - `scaling.sh`: this script is used to run NuMorphs scaling experiment (processing multiple samples)

- `benchmark.config`: config file to allow nf-core/lsmquant as much resources as the process wants. The resource limits are set to the hardware limits.
- `resource_and_scalin_results.ipynb`: Jupyter notebook that was used to aggregate raw data and generate the figures and results for resource usage and scaling experiments.

functional_equivalence_testing: 
- Figures 
- `