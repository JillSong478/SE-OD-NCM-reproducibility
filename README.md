# SE-OD-NCM Reproducibility Materials

This repository provides MATLAB simulation and analysis scripts, model parameter settings, and extended methodological materials supporting the manuscript:

**A thalamocortical neural mass model of stage-specific discharge patterns and oxygen-deficit burden in status epilepticus**

The model incorporates KCC2-dependent chloride regulation, NMDA-mediated excitation, and oxygen-coupled ionic homeostasis into a thalamocortical neural mass framework to investigate SE-like electrophysiological patterns and cumulative oxygen-deficit burden.

## 1. Requirements

- MATLAB R2022a
- Explicit Euler integration with a nominal time step of 0.01 ms
- Figure-specific parameters, initial conditions, and random seeds as described in Appendix A and the accompanying methodological materials

## 2. MATLAB Scripts and Figure Correspondence

| Figures / Analyses | MATLAB scripts | Description |
|---|---|---|
| Figs. 2–8 | `try_0515oxygen.m` | Simulation of representative SE-like electrophysiological patterns using prescribed parameter settings |
| Fig. 9 | `classify_Vp_state.m`, `stage.m` | Classification and visualization of model-generated dynamical regimes |
| Fig. 10 | `extract_pilocarpine_SE_30s.m` | Extraction of 30-s EEG segments from the experimental rat SE dataset |
| Fig. 10 | `SE_feature_extraction_kNEO_burst_delta.m` | Event and burst feature extraction from experimental EEG recordings |
| Fig. 10 | `feamodel.m` | Simulation and feature extraction for the model-generated signals |
| Fig. 10 | `compare_Type134_PSD.m` | Quantitative spectral comparison between experimental and simulated signals |
| Figs. 11–12 | `try_0515oxygen.m` | Oxygen dynamics and hypoxia index (HI) simulations under different oxygen-supply conditions |
| Fig. 13 | `stage.m` | Visualization of representative stage-specific SE-like patterns |
| Fig. 14 | `try_0515oxygen_HI.m` | Parameter-space calculations of cumulative HI |
| Fig. 14 | `brain_injury_plot.m` | Visualization of HI parameter-space heat maps |
| HI threshold sensitivity | `Sensitivity_threshold.m` | Sensitivity analysis of HI with respect to the selected oxygen threshold |
| GABAergic intervention | `GABA_intervention_KCC2_10seeds.m` | GABAergic potentiation under different KCC2 recovery conditions |
| NMDA intervention | `NMDA_intervention_KCC2_10seeds.m` | NMDA attenuation under different KCC2 recovery conditions |

Some scripts are used for multiple figures by changing the predefined model parameters or oxygen-supply settings.

Fig. 15 is a conceptual summary of the results rather than a separately simulated output.

## 3. Running the Simulations

1. Download or clone this repository.
2. Open MATLAB and set the working directory to the folder containing the scripts.
3. Select the script corresponding to the desired figure or analysis.
4. Set the required model parameters, random seeds, and input paths according to the manuscript and extended methodological materials.
5. Run the script to reproduce the corresponding simulations or analyses.

For Figs. 2–8 and 11–12, `try_0515oxygen.m` is used with different parameter configurations.

For Fig. 14, `try_0515oxygen_HI.m` performs the HI parameter scans, while `brain_injury_plot.m` generates the heat maps from the calculated results.

The simulated stage-specific patterns are generated independently using prescribed parameter configurations rather than through endogenous progression or recovery between stages.

## 4. Independent Experimental EEG Data

The experimental comparison in Fig. 10 uses publicly available rat pilocarpine-status-epilepticus EEG recordings from:

**Hyder et al. (2025). EEG Recordings for: Optogenetic stimulation of the dorsal striatum bidirectionally controls seizures.**

Dryad dataset: https://doi.org/10.5061/dryad.f7m0cfz6w

The analysis includes 11 rats, with four EEG channels aggregated within each rat. The experimental recordings are not assigned Type 1–4 phenotype-specific labels.

### Experimental-data processing

The Fig. 10 analysis involves the following scripts:

1. `extract_pilocarpine_SE_30s.m` — extracts 30-s EEG segments beginning 5 min after annotated SE onset.
2. `SE_feature_extraction_kNEO_burst_delta.m` — calculates experimental discharge and burst features.
3. `feamodel.m` — generates and analyzes the simulated SE-like signals.
4. `compare_Type134_PSD.m` — compares the spectral characteristics of experimental and simulated recordings.

The experimental and simulated signals in Fig. 10 are analyzed using the same k-point nonlinear energy operator (k-NEO) for event detection.

The peak-based criteria used for dynamical-state classification in Fig. 9 are separate from the k-NEO procedure used for the independent experimental comparison.

**Data availability:** The original experimental EEG recordings are not redistributed in this repository. Users should download them from Dryad and update the local data paths in the relevant MATLAB scripts.

## 5. Intervention Simulations

The intervention analyses examine changes in model-generated SE-like discharge activity under different KCC2-mediated chloride-recovery conditions.

### GABAergic potentiation

Script: `GABA_intervention_KCC2_10seeds.m`

- GABAergic scaling factor: W_GABA = 1.0 → 1.25
- Intervention time: 20 s
- KCC2 recovery time constants: 6500, 8000, and 10000 ms
- Stochastic realizations: 10 per condition
- Pre-intervention analysis: 10–20 s
- Post-intervention analysis: 30–40 s

### NMDA attenuation

Script: `NMDA_intervention_KCC2_10seeds.m`

- NMDA scaling factor: W_NMDA = 4 → 1
- Intervention time: 20 s
- KCC2 recovery time constants: 6500, 8000, and 10000 ms
- Stochastic realizations: 10 per condition
- Pre-intervention analysis: 10–20 s
- Post-intervention analysis: 30–40 s

Both analyses examine discharge-rate changes and model-based dynamical-state classifications.

These interventions are phenomenological parameter manipulations and should not be interpreted as quantitative models of clinical drug efficacy.

## 6. Additional Analyses

The repository and accompanying methodological materials support additional analyses of:

- HI sensitivity to the oxygen-deficit threshold.
- HI differences between normal and SE-like configurations under matched oxygen availability.
- Stochastic variability across repeated simulations.
- Numerical robustness to integration time-step changes.
- GABAergic and NMDA-related intervention responses.

The relevant simulation settings and summary results are described in the extended methodological materials.

## 7. Extended Methodological and Reproducibility Materials

The accompanying **Extended Methodological and Reproducibility Materials** provide further details on the model equations, parameters, initial conditions, numerical methods, experimental comparisons, sensitivity analyses, and intervention simulations.

These materials complement Appendix A of the manuscript and should be consulted when reproducing the reported results.

## 8. Interpretation and Limitations

The hypoxia index (HI) is a model-based proxy for cumulative oxygen-deficit burden and has not been validated against histological, imaging, or clinical markers of neuronal injury.

The independent experimental comparison shows partial correspondence with established SE activity rather than phenotype-specific experimental validation.

## 9. Citation

Please cite the associated manuscript and the corresponding archived version of this repository when using these materials.

A version-specific Zenodo DOI will be added after the final release.
