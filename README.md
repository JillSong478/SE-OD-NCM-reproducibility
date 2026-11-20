# SE-OD-NCM Reproducibility Materials

This repository contains MATLAB simulation and analysis scripts, figure-specific parameter settings, selected intermediate HI-map data, and extended methodological materials supporting the manuscript:

**A thalamocortical neural mass model of stage-specific discharge patterns and oxygen-deficit burden in status epilepticus**

The SE-OD-NCM combines thalamocortical population dynamics with KCC2-dependent chloride regulation, NMDA-mediated excitation, and oxygen-coupled ionic homeostasis. The hypoxia index (HI) quantifies *model-based cumulative oxygen-deficit burden*; it is not a validated measure of neuronal injury.

## 1. Software and General Notes

- **Software:** MATLAB R2022a. Some scripts use functions such as `findpeaks`, `resample`, `pwelch`, and `boxplot`; the corresponding MATLAB toolboxes may be required.
- **Numerical integration:** Explicit Euler method, typically with a time step of 0.01 ms.
- **Analysis windows:** For the standard 45-s simulations, the first 10 s are discarded and the 10–40-s window is analyzed. Fig. 10 uses 40-s simulations with a 10-s transient and a 30-s analysis window.
- **Randomness:** Prescribed random seeds are used for reproducibility. Parameter comparisons use matched stochastic inputs, while repeated-seed analyses assess variability.
- **Model stages:** Representative onset, continuous, and convalescence patterns are generated from independently prescribed parameter configurations, not through endogenous stage progression.

For model equations, initial conditions, and stage-specific settings, see Appendix A and the accompanying **Extended Methodological and Reproducibility Materials**, particularly Tables S2 and S3.

## 2. MATLAB Scripts and Figure Correspondence

| Figure / Analysis | MATLAB Script(s) | Description |
|---|---|---|
| Figs. 2–8 | `try_0515oxygen.m` | Simulation of representative SE-like electrophysiological patterns |
| Fig. 9 | `classify_Vp_state.m`, `stage.m` | Classification and visualization of model-generated dynamical regimes |
| Fig. 10 | `extract_pilocarpine_SE_30s.m` | Extraction of 30-s segments from experimental rat SE recordings |
| Fig. 10 | `SE_feature_extraction_kNEO_burst_delta.m` | Experimental event and burst feature extraction using k-NEO |
| Fig. 10 | `feamodel.m` | Simulation and feature extraction for model-generated signals |
| Fig. 10 | `compare_Type134_PSD.m` | Quantitative comparison of experimental and simulated signals |
| Figs. 11–12 | `try_0515oxygen.m` | Oxygen dynamics and HI simulations |
| Fig. 13 | `stage.m` | Visualization of representative stage-specific patterns |
| Fig. 14 | `try_0515oxygen_HI.m` | HI parameter-space calculations |
| Fig. 14 | `brain_injury_plot.m` | Visualization of HI parameter-space heat maps |
| Fig. 14 stochastic sensitivity | `Fig14_seed_robustness.m` | Comparison of HI maps obtained using three random seeds |
| GABAergic intervention | `GABA_intervention_KCC2_10seeds.m` | Original GABAergic potentiation analysis |
| NMDA intervention | `NMDA_intervention_KCC2_10seeds.m` | Original NMDA attenuation analysis |
| Extended GABAergic intervention | `GABA_intervention_review11_4.m` | Extended KCC2 conditions, chloride dynamics, and potentiation strengths |
| GABAergic intervention comparison | `GABA_review11_4_compare_doses.m` | Control-adjusted comparison using matched random seeds |

Additional scripts, including `four_state.m` and `GABA_intervention_10seeds_complete.m`, are retained as supporting materials.

Some figures require separate runs with different prescribed model parameters. Fig. 15 is a conceptual summary rather than an independently simulated output.

## 3. Running the Simulations

1. Download or clone the repository.
2. Open MATLAB and set the working directory to the repository folder.
3. Select the relevant simulation or analysis script.
4. Set the required parameters, random seeds, and local input paths according to Appendix A and the extended methodological materials.
5. Run the corresponding scripts to generate and analyze the results.

The repository is not a single-command reproduction pipeline. Certain figures require manual selection of predefined parameter configurations.

## 4. Independent Experimental EEG Data and Fig. 10

The independent experimental comparison uses publicly available rat pilocarpine-status-epilepticus recordings:

**Hyder et al. (2025). EEG Recordings for: Optogenetic stimulation of the dorsal striatum bidirectionally controls seizures.**

Dryad DOI: https://doi.org/10.5061/dryad.f7m0cfz6w

The analysis includes 11 rats, with four EEG channels aggregated within each rat. The L/R suffixes are part of the original animal identifiers; channels and hemispheres are not treated as independent animal observations.

The experimental recordings do not contain Type 1–4 phenotype-specific labels.

### Processing workflow

1. `extract_pilocarpine_SE_30s.m` extracts experimental 30-s EEG segments beginning 5 min after annotated SE onset.
2. `SE_feature_extraction_kNEO_burst_delta.m` extracts experimental discharge-event and burst features.
3. `feamodel.m` generates and analyzes simulated SE-like signals.
4. `compare_Type134_PSD.m` performs the experimental–simulation comparison.

For Fig. 10, experimental and simulated signals are analyzed using the same k-point nonlinear energy operator (k-NEO) for event detection.

The peak-based detection criteria used for dynamical-state classification in Fig. 9 are separate from the k-NEO procedure used for Fig. 10.

Realizations without qualifying bursts have undefined median burst duration but remain included in discharge-rate and spectral analyses.

**Data availability:** The original experimental recordings are not redistributed here. Users should obtain the data from Dryad and update the local data paths in the MATLAB scripts.

## 5. HI Parameter-Space Analysis and Stochastic Robustness

### 5.1. Fig. 14 parameter-space analysis

The parameter scan covers:

- KCC2 recovery time constant: τ_KCC2 = 1000–10,000 ms, in 500-ms increments.
- External oxygen availability: [O₂]bath = 24–28 mg/L, in 0.25-mg/L increments.
- NMDA Mg²⁺-block parameter: k = 0.95, 0.8, and 0.7.
- Nominal HI threshold: Thr = 24 mg/L.
- Integration time step: 0.01 ms.
- Total simulation duration: 45 s.
- Transient removal: first 10 s.
- HI accumulation window: 10–40 s (30 s).

Other model parameters follow the Continuous Type 1 configuration, except those varied in the scan.

`try_0515oxygen_HI.m` calculates the HI parameter-space values, and `brain_injury_plot.m` generates the heat maps.

### 5.2. Stochastic sensitivity of Fig. 14

The complete parameter-space scan was repeated using three random seeds (1–3), with the same stochastic realization applied across parameter combinations within each scan.

Nine MATLAB data files are provided as inputs to `Fig14_seed_robustness.m`:

| k | Seed 1 | Seed 2 | Seed 3 |
|---|---|---|---|
| 0.70 | `HI_plot_07_seed1.mat` | `HI_plot_07_seed2.mat` | `HI_plot_07_seed3.mat` |
| 0.80 | `HI_plot_08_seed1.mat` | `HI_plot_08_seed2.mat` | `HI_plot_08_seed3.mat` |
| 0.95 | `HI_plot_095_seed1.mat` | `HI_plot_095_seed2.mat` | `HI_plot_095_seed3.mat` |

These files contain the saved HI parameter-space results and allow direct reproduction of the stochastic-sensitivity statistics without rerunning the complete parameter scan.

To reproduce the analysis, place the nine files in the directory expected by `Fig14_seed_robustness.m` and run the script. The filename tags should match `07`, `08`, and `095`.

The script calculates pairwise Pearson correlations between log10(HI + 1) maps, pointwise variability, and agreement in zero/nonzero HI regions.

The pairwise spatial correlations were:

| k | Pearson correlation range | Zero/nonzero HI agreement |
|---|---|---|
| 0.95 | 0.9966–0.9977 | 91.64% |
| 0.80 | 0.9799–0.9889 | 91.64% |
| 0.70 | 0.9171–0.9382 | 90.40% |

The overall parameter-dependent HI distributions were largely preserved across stochastic realizations, although local variability was more pronounced at k = 0.7.

The original HI maps can also be regenerated using `try_0515oxygen_HI.m` with the corresponding parameter settings and random seeds.

## 6. Intervention Simulations

### 6.1. Original GABAergic and NMDA interventions

The original intervention analyses use:

- τ_KCC2 = 6500, 8000, and 10,000 ms.
- 10 stochastic realizations per condition.
- Intervention time: 20 s.
- Pre-intervention analysis: 10–20 s.
- Post-intervention analysis: 30–40 s.

**GABAergic potentiation**

Script: `GABA_intervention_KCC2_10seeds.m`

W_GABA is increased from 1.0 to 1.25.

**NMDA attenuation**

Script: `NMDA_intervention_KCC2_10seeds.m`

W_NMDA is reduced from 4 to 1.

Both analyses quantify discharge-rate changes and model-based dynamical-state classifications.

### 6.2. Extended GABAergic intervention analysis

Script: `GABA_intervention_review11_4.m`

The extended analysis considers seven KCC2 recovery conditions:

τ_KCC2 = 1000, 3000, 5000, 6500, 8000, 10,000, and 15,000 ms.

Four GABAergic scaling conditions are examined:

- W_GABA = 1.00 (untreated control).
- W_GABA = 1.25.
- W_GABA = 1.50.
- W_GABA = 2.00.

Each condition uses 10 stochastic realizations.

In addition to discharge rate and dynamical-state classification, the analysis evaluates E_GABA and intracellular chloride concentration inferred from the modeled chloride reversal potential using the Nernst relationship.

### 6.3. Control-adjusted intervention comparison

Script: `GABA_review11_4_compare_doses.m`

To distinguish intervention effects from spontaneous changes in discharge rate, treated and untreated simulations are compared using matched random seeds and the same post-intervention window (30–40 s).

**Running order:**

First run `GABA_intervention_review11_4.m` separately with W_GABA = 1.00, 1.25, 1.50, and 2.00.

This generates the following intermediate CSV files:

```text
GABA_W1p00_10seeds_trials.csv
GABA_W1p25_10seeds_trials.csv
GABA_W1p50_10seeds_trials.csv
GABA_W2p00_10seeds_trials.csv
```

Then run `GABA_review11_4_compare_doses.m` to calculate the control-adjusted discharge-rate reductions.

Only realizations classified as continuous SE-like before intervention are included in the established-SE comparison. Consequently, eligible sample sizes may differ across KCC2 conditions.

These interventions are phenomenological synaptic-scaling manipulations rather than calibrated clinical drug doses. They do not establish progressive clinical benzodiazepine resistance or prove that NMDA excitation is necessary for maintaining continuous SE-like activity.

## 7. Extended Methodological and Reproducibility Materials

The accompanying **Extended Methodological and Reproducibility Materials** provide further details on:

- S2–S3: Model parameters, initial conditions, and stage-specific configurations.
- S4: Operational dynamical-state classification.
- S5: Experimental EEG processing, k-NEO event detection, burst definitions, PSD estimation, and quantitative comparisons.
- S6: HI threshold sensitivity, normal/SE-like HI robustness, numerical-step sensitivity, and stochastic sensitivity of HI parameter-space maps.
- S7: Original and extended intervention analyses, chloride-related dynamics, and control-adjusted GABAergic responses.

These materials complement Appendix A of the manuscript and provide additional numerical settings, statistical results, and supporting figures.

## 8. Citation and Versioning

Please cite the associated manuscript and the corresponding archived version of this repository when using these materials.

Public repository:

https://github.com/JillSong478/SE-OD-NCM-reproducibility

A version-specific Zenodo DOI will be added after the final GitHub Release is published and archived.
