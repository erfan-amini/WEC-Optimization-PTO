# Wave Energy Converter Power Take‑Off Optimization using Multi‑Verse Optimizer (MVO)

[![MATLAB](https://img.shields.io/badge/MATLAB-R2019b+-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## 📋 Overview

This repository contains the MATLAB implementation of the **Multi‑Verse Optimizer (MVO)** algorithm for optimizing Power Take‑Off (PTO) parameters of a fully‑submerged three‑tether Wave Energy Converter (WEC). The code accompanies the research paper:

> **A Comparative Study of Metaheuristic Algorithms for Wave Energy Converter Power Take‑Off Optimisation: A Case Study for Eastern Australia**
> Amini, E., Golbaz, D., Asadi, R., Nasiri, M., Ceylan, O., Majidi Nezhad, M., & Neshat, M. (2021).
> *Journal of Marine Science and Engineering*, 9(5), 490.
> DOI: [10.3390/jmse9050490](https://doi.org/10.3390/jmse9050490)

## 🎯 Purpose

The project optimizes the PTO system of a spherical buoy WEC developed by Carnegie Clean Energy Company. The optimization aims to maximize power output by finding optimal spring stiffness (**kPTO**) and damping (**dPTO**) coefficients for three tethers across 50 frequency samples, resulting in **300** decision variables.

## 📁 Repository Structure

```text
wave-energy-converter-mvo/
│
├── README.md                    # This file
├── LICENSE                      # License information
│   ├── Main_MVO.m               # Main script to run optimization
│   ├── MVO.m                    # Multi-Verse Optimizer implementation
│   ├── transformation.m         # Transform optimization variables to WEC parameters
│   ├── Initialize_firstpop.m    # Initialize first population
│   ├── initialization_MVO.m     # MVO-specific initialization
│   ├── spectrum_PMw.m           # Pierson–Moskowitz wave spectrum
│   ├── optimalPTO.m             # PTO optimization functions
│   ├── histcn.m                 # N-dimensional histogram utility
│   ├── Get_Functions_details.m  # Benchmark test functions
│   ├── func_plot.m              # Function plotting utilities
│   └── main.m                   # Demo script for benchmark functions
│
├── DATA/                        # Input data files
│   ├── 04Sydney.nc              # Wave hindcast data (1979–2013)
│   └── ptoParameters.mat        # Pre-calculated PTO parameters
│
└── RESULTS/                     # Optimization results
    ├── Sydney_PTO_MVO_NUni_25_id_1.mat
    ├── Sydney_PTO_MVO_NUni_25_id_2.mat
    ├── Sydney_PTO_MVO_NUni_25_id_3.mat
    └── Sydney_PTO_MVO_NUni_25_id_4.mat
```

## 🔧 Requirements

* **MATLAB** R2019b or later
* Toolboxes:

  * Optimization Toolbox
  * Statistics and Machine Learning Toolbox
* **WEC‑Sim** toolbox dependencies (for WEC simulation)
* NetCDF support for reading wave data

## 🚀 Getting Started

### Installation

1. Clone this repository:

```bash
git clone https://github.com/yourusername/wave-energy-converter-mvo.git
cd wave-energy-converter-mvo
```

2. Add the project to your MATLAB path:

```matlab
addpath(genpath('wave-energy-converter-mvo'))
```

### Running the Optimization

1. **Main optimization run:**

```matlab
% Run the main MVO optimization
Main_MVO
```

2. **Customize parameters** in `Main_MVO.m`:

```matlab
Opt.SN = 25;          % Number of search agents
Opt.Maxiter = 10000;  % Maximum iterations
Opt.WaveModel = 4;    % 1:Perth, 2:Adelaide, 3:Tasmania, 4:Sydney
```

3. **Run benchmark tests** (optional):

```matlab
% Test MVO on standard benchmark functions
main
```

## 📊 Data Description

### Input Data (`DATA/`)

1. **`04Sydney.nc`** — Wave hindcast dataset

   * **Coverage:** 1979‑01‑01 to 2013‑05‑31 (hourly)
   * **Location:** Sydney coast (152.5°E, −34.0°S)
   * **Variables:**

     * `hs` — Significant wave height (m)
     * `fp` — Peak frequency (Hz)
     * `tm0m1` — Mean wave period (s)
     * `dir` — Wave direction (degrees)
   * **Records:** \~301,680 hourly observations
2. **`ptoParameters.mat`** — Pre‑calculated optimal PTO parameters

   * Contains lookup tables for different buoy radii
   * Frequency‑dependent **kPTO** and **dPTO** values

### Output Data (`RESULTS/`)

Each `.mat` file contains:

* `generation[400]` — Array of best fitness values per iteration
* Represents independent optimization runs (`id_1` to `id_4`)
* Useful for statistical analysis and convergence studies

## 📈 Algorithm Details

### Multi‑Verse Optimizer (MVO)

The MVO algorithm simulates the concept of multi‑verse theory in physics:

* **White holes:** Transfer objects between universes (exploration)
* **Black holes:** Attract objects (exploitation)
* **Wormholes:** Provide local changes (local search)

Key parameters:

* Wormhole Existence Probability (WEP): \[0.2, 1]
* Travelling Distance Rate (TDR): Adaptive parameter

### Optimization Problem

* **Objective:** Maximize annual average power output
* **Decision variables:** 300 (50 kPTO + 50 dPTO per tether × 3 tethers)
* **Constraints:**

  * kPTO: \[1, 550,000] N/m
  * dPTO: \[50,000, 400,000] Ns/m

## 📊 Results Analysis

The optimization results show:

* **Best power output:** \~272.5 kW (MVO algorithm)
* **Convergence:** Typically within 6,000–8,000 evaluations
* **Performance ranking:** MVO > CMA‑ES > GWO > GOA > HHO

To analyze results:

```matlab
% Load and plot convergence curves (robust to different "generation" formats)
S = load('RESULTS/Sydney_PTO_MVO_NUni_25_id_1.mat');
g = S.generation;
if isstruct(g) && isfield(g, 'ParrayW')
    y = g.ParrayW;
elseif isnumeric(g)
    y = g;
else
    error('Unknown generation format; inspect the MAT file contents.');
end
plot(y); grid on;
xlabel('Iteration'); ylabel('Power Output (W)');
title('MVO Convergence Curve');
```

## 🤝 Contributing

Contributions are welcome! Please open an issue to discuss major changes before submitting a PR.

## 📝 Citation

If you use this code in your research, please cite:

```bibtex
@article{amini2021comparative,
  title={A Comparative Study of Metaheuristic Algorithms for Wave Energy Converter Power Take-Off Optimisation: A Case Study for Eastern Australia},
  author={Amini, Erfan and Golbaz, Danial and Asadi, Rojin and Nasiri, Mahdieh and Ceylan, O{\u{g}}uzhan and Majidi Nezhad, Meysam and Neshat, Mehdi},
  journal={Journal of Marine Science and Engineering},
  volume={9},
  number={5},
  pages={490},
  year={2021},
  publisher={MDPI},
  doi={10.3390/jmse9050490}
}
```

## 📧 Contact

For questions or collaborations:

* **Mehdi Neshat** — [mehdi.neshat@adelaide.edu.au](mailto:mehdi.neshat@adelaide.edu.au)

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

* Carnegie Clean Energy Company for the WEC design specifications
* Australian Wave Energy Atlas for wave data
* Original MVO algorithm by Seyedali Mirjalili

---

**Note:** This is research code. While we strive for accuracy, please verify results independently for production use.
