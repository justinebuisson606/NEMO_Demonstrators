# NEMO Demonstrators

**Welcome to the documentation for NEMO Demonstrators.**

## What is this?

A collection of small, reproducible experiments run with the
[NEMO](https://www.nemo-ocean.eu) ocean model, each paired with the theory and
the analysis code needed to understand the result.

## Where to start

- [User Guide](user_guide/index.md): experiment set-up and data layout.
- [Demonstrators](demonstrators.md): the notebooks and their NEMO configurations.
- [Methodology](recipes.md): notes and theoretical explanations on the notebooks.
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
