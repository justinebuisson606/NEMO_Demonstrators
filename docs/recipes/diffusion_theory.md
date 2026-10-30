# Dispersive scheme 

## Problem

In simulations, time and space are divided into discrete grids and the continuous differential equations of motion 
(such as the Navier–Stokes equation) are discretized into finite-difference equations, these discrete equations are in general 
unidentical to the original differential equations, so the simulated system behaves differently than the intended physical system.


## Study of a first order diffusive scheme (UP1): 

Consider the 1D linear advection equation with constant velocity $c$:

$$
\frac{\partial T}{\partial t}+c\frac{\partial T}{\partial x}=0
$$

The spatial discretisation of the transport equation is as follows :

$$
\partial_x T_j \approx \frac{T_{j} - T_{j-1}}{\Delta x} 
$$

Using a Taylor series expansion to evaluate the truncation error : 

$$
\frac{T_{j} - T_{j-1}}{2\Delta x} = \partial_x T + \frac {\Delta x }{2} \partial_x^2 T + \mathcal{O}(\Delta x ^2)
$$

Substituting this back into the governing equation reveals the **modified equation**:

$$
\frac{\partial T}{\partial t}+c\frac{\partial T}{\partial x}= - c \frac {\Delta x }{2} \partial_x^2 T + \mathcal{O}(\Delta x ^2)
$$


The presence of the 2nd-order spatial derivative $\frac{\partial ^{2}T}{\partial x^{2}}$ mathematically dictates that the scheme is purely diffusive.

## Physical consequences of diffusion

The consequence of the dispersion is that even-order derivative errors act like numerical viscosity.
The viscosity dampens the signal, smoothes out the edges. When resolving sharp profiles (like a step function or square pulse) 
a diffusive model will reduce the high magnitude gradients, turning a steep slop into a gentle slope, a step into a hill. 

Intricate structures like eddies will become less structured at small scales.


