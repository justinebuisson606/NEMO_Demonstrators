# Run the demonstrators yourself

This website is **static**: GitHub Pages serves pre-rendered pages and cannot run
code or launch NEMO. The notebooks shown under *Demonstrators* therefore display
the outputs saved in the notebooks, and the buttons below take you to an
environment where you can run them.

## What can run where

| Part | On this website | Binder / Codespaces | Your machine or HPC |
|---|---|---|---|
| Reading notebooks, figures | yes | yes | yes |
| Analysis cells (plots from existing NetCDF output) | no | yes, if the output files are in the repository | yes |
| Launching NEMO simulations (`.sh` scripts) | no | **no** (NEMO must be compiled, MPI, input data) | yes |

!!! warning
    The `.sh` scripts that start simulations need a working NEMO installation.
    They cannot run on GitHub Pages, in Binder, or in a standard Codespace.

## 1. Run locally (full workflow, including simulations)

```bash
git clone https://github.com/justinebuisson606/NEMO_Demonstrators.git
cd NEMO_Demonstrators
# unzip the configuration for the demonstrator you want, e.g.
unzip demo1_cfg.zip
# then open the notebook, which calls the .sh scripts
jupyter lab "Demonstrator 1.ipynb"
```

Prerequisites: a compiled NEMO (see the
[NEMO documentation](https://sites.nemo-ocean.io/user-guide/)), Python with
`jupyterlab`, `numpy`, `matplotlib`, `xarray`, `netcdf4`.

## 2. Analysis only, in the browser

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/justinebuisson606/NEMO_Demonstrators/main)
[![Open in Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/justinebuisson606/NEMO_Demonstrators)

These open the repository in a Jupyter environment. For Binder to work, the
repository needs an `environment.yml` or `requirements.txt` (a template is provided
in `binder/`). Cells that call the simulation scripts will fail there.

## 3. Optional: ship the simulation output

To make the analysis cells runnable online, commit the (small) NetCDF output files
used by the figures, or host them (Zenodo, for example) and download them at the
start of the notebook.
