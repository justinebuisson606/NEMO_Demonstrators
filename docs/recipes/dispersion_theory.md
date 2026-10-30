# Dispersive scheme 

## Problem

In simulations, time and space are divided into discrete grids and the continuous differential equations of motion 
(such as the Navier–Stokes equation) are discretized into finite-difference equations, these discrete equations are in general 
unidentical to the original differential equations, so the simulated system behaves differently than the intended physical system.


An example of a dispersive scheme in NEMO 5.0 is the CENtred advection scheme (CEN).

## Study of a second order dispersive scheme (CEN2): 

Consider the 1D linear advection equation with constant velocity $c$:

$$
\frac{\partial T}{\partial t}+c\frac{\partial T}{\partial x}=0
$$

The spatial discretisation of the transport equation is as follows :

$$
\partial_x T_j \approx \frac{T_{j+1} - T_{j-1}}{2\Delta x} 
$$

Using a Taylor series expansion to evaluate the truncation error : 

$$
\frac{T_{j+1} - T_{j-1}}{2\Delta x} = \partial_x T + \frac {\Delta x ^2}{6} \partial_x^3 T + \mathcal{O}(\Delta x ^4)
$$

Substituting this back into the governing equation reveals the **modified equation**:

$$
\frac{\partial T}{\partial t}+c\frac{\partial T}{\partial x}= - c \frac {\Delta x ^2}{6} \partial_x^3 T + \mathcal{O}(\Delta x ^4)
$$


The presence of the 3rd-order spatial derivative $\frac{\partial ^{3}T}{\partial x^{3}}$ mathematically dictates that the scheme is purely dispersive rather than dissipative.

## Physical consequences of dispersion 

The consequence of the dispersion is that every numerical wave component travels slower than the true physical speed c. 
When resolving sharp profiles (like a step function or square pulse) containing high frequencies, 
these high-frequency components lag severely behind the main wave packet. 
This results in unphysical oscillations trailing behind the wavefront. Overall the signal loses its shape.

These wiggles are called side lobes and result in tracer values out of the authorised bounds of the initial distribution of the tracer. 
This can be quite problematic because it can generate unphysical values of the tracers (eg. negative salinity).
