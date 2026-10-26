# NEMO Demonstrators

**Welcome to the documentation for NEMO Demonstrators.**

## What is this?

A collection of small, reproducible experiments run with the
[NEMO](https://www.nemo-ocean.eu) ocean model, each paired with the theory and
the analysis code needed to understand the result.

The first demonstrator studies **numerical dispersion** of advection schemes
(CEN2, CEN4, UBS, FCT2, FCT4): a block of salt (35 psu) is advected by a uniform
zonal current over a 30 psu background, and the deformation of the block is
compared with the theoretical phase and group velocities of each scheme.

## Where to start

- [User Guide](user_guide/index.md): experiment set-up and data layout.
- [Demonstrators](demonstrators.md): the notebooks and their NEMO configurations.
- [Recipes](recipes/index.md): theory and analysis scripts.
- [Contributing](contributing.md): add your own demonstrator.

## Installation

```bash
git clone https://github.com/justinebuisson606/NEMO_Demonstrators.git
cd NEMO_Demonstrators
python -m venv env_demo && source env_demo/bin/activate
pip install numpy matplotlib xarray netcdf4
```

## Build this site locally

```bash
pip install -r requirements-docs.txt
mkdocs serve
```
