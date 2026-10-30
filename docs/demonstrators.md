# Demonstrators

Each demonstrator is a notebook, with the NEMO configuration used to run it.
The pages show saved outputs; to run the simulations, see [Run it yourself](run_yourself.md).
All configuration parameters are gathered in the [configuration table](recipes/configurations.md)

| Notebook | | NEMO configuration file|
|---|---|---|
| [Demonstrator 1](notebooks/demonstrator_1.ipynb)  | The aim of this tutorial is to give the readers an opportunity to run the salt block simulation using the different advection schemes. Here we choose to use the transport of a block of salt to demonstrate how the diffusive and dispersive properties of the advection scheme impact the outcome of a simulation. | [demo1_cfg](https://github.com/justinebuisson606/NEMO_Demonstrators/raw/main/demo1_cfg) |
| [Demonstrator 1 (gauss)](notebooks/demonstator_1-gauss.ipynb) | The aim of this tutorial is to further dive into the dispersive and diffusive properties of the tracer advection schemes. Here we choose to transport sinusoidal signals at different frequencies to compare the performances of the different schemes based on the spatial resolution of the signal. | [demo2_cfg](https://github.com/justinebuisson606/NEMO_Demonstrators/raw/main/demo_gauss) |
| [Demonstrator 2](notebooks/demonstrator_2.ipynb) | Here we choose to demonstrate how the diffusive and dispersive properties of the advection scheme impact the outcome of a simulation in the case of the formation of eddies. | [demo3_cfg](https://github.com/justinebuisson606/NEMO_Demonstrators/raw/main/demo2_cfg) |
| [Demonstrator 3](notebooks/demonstrator_3.ipynb) | The aim of this tutorial is to dive into the interest of combining a diffusive operator with a dispersive scheme. FCT and UBS methods are examples of schemes where the numerical expression of the methods contains a dispersive term and a diffusive term. Here we choose to deliberately add a diffusive operator to a solely dispersive scheme (CEN) on the saltblock experience to attest of the benefits of having both properties. | [demo4_cfg](https://github.com/justinebuisson606/NEMO_Demonstrators/raw/main/demo3_cfg) |
| [Annex 1 - Saltblock moving diagonally](notebooks/annex_1.ipynb) | This tutorial slightly complexifies the salt block simulation by changing from unidirectional advection to bi-directional advection and showcases the its consequences. | [annex1_cfg](https://github.com/justinebuisson606/NEMO_Demonstrators/raw/main/annex1_cfg) |
| [Annex 3 - CEN4 + BILAP = UBS](notebooks/annex_3-a.ipynb) | The aim of this tutorial is to prove that the CEN4 combined with a Bi-Laplacian diffusion is equivalent to the UBS scheme. | [annex3_cfg](https://github.com/justinebuisson606/NEMO_Demonstrators/raw/main/annex3_cfg) |

