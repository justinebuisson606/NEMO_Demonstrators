# Numerical dispersion: theory

## Problem and strategy
 
We solve the 1D advection equation with a uniform velocity $c_0 > 0$, in a periodic domain:
 
$$
\frac{\partial T}{\partial t} + c_0 \frac{\partial T}{\partial x} = 0 .
$$
 
**Why sinusoids?** Any signal can be decomposed into a sum of sinusoids. If the scheme is **linear** and the current **uniform**, each Fourier mode evolves independently of the others. It is therefore enough to understand what the scheme does to
**one** sinusoid; the signal is then the sum of all of them.
 
**Exact solution.** For $T = e^{i(kx - \omega t)}$ the equation gives
 
$$
-i\omega + i c_0 k = 0 \quad\Longrightarrow\quad \omega = c_0 k ,
$$
 
so every wave travels at the same speed $c_p = \omega/k = c_0$: there is no dispersion.
A numerical scheme changes the relation $\omega(k)$; this is what we compute below.

## CEN2 : Expression of $c_p$

The spatial discretisation of the transport equation is as follows :

$$
\partial_x T \approx \frac{T_{j+1} - T_{j-1}}{2\Delta x} = \frac{e^{i\theta} - e^{-i\theta }}{2\Delta x} T_j= \frac{2i \sin\theta}{2\Delta x} T_j
$$

The time continuous part of the transport equation becomes :

$\partial_t T = -i\omega T_j$

Which gives us     $c_p = \frac{\omega}{k} = c_0 \sin\theta/\theta$

**Small $\theta$ expansion** 

$$
\frac{c_p}{c_0} = \frac{\sin\theta}{\theta} = 1 - \frac{\theta^2}{6} + \frac{\theta^4}{120} - \dots
$$

Waves are always **slower** than $c_0$, the more so the shorter they are. At $\theta = \pi$,
$c_p = 0$: the $2\Delta x$ wave does not move.

## CEN4 : Expression of $c_p$

The CEN4 scheme can be expressed as follows : $T_j^{cen4} = T_j^{cen2} - \frac{1}{6} \overline{ \delta_j \left[ \delta_{j+1/2}[T] \right]}^{j+1/2} $
with $\overline{T}^{j+1/2} = (T_{j+1} + T_j)/2$
and 
$\delta_j[T] = (T_{j+1} - T_j)$

The spatial discretisation of the transport equation is as follows :

$$
\partial_x T \approx \frac{4}{3} \frac{T_{j+1} - T_{j-1}}{2\Delta x} - \frac{1}{6} \frac{T_{j+2} - T_{j-2}}{2\Delta x}
= (\frac{4}{3}\frac{e^{i\theta} - e^{-i\theta }}{2\Delta x} -\frac{1}{6}\frac{e^{i2\theta} - e^{-i2\theta }}{\Delta x} ) T_j\
= (\frac{4}{3} \frac{i \sin\theta}{\Delta x} -\frac{1}{6}\frac{i \sin2\theta}{\Delta x}) T_j$
$$

The time continuous part of the transport equation becomes :

$\partial_t T_j = -i\omega T_j$

Which gives us     $c_p = \frac{\omega}{k} = c_0 (\frac{4}{3} \sin\theta/ - \frac{1}{6} \sin2\theta )/\theta$

**Small $\theta$ expansion** 

Therefore $c_p/c_0 \approx 1 - \theta^4/30$: the phase error is of order 4
instead of order 2 for CEN2.

## UBS : Expression of $c_p$

For $c_0>0$, the discrete spatial derivative uses one point downstream and two upstream :

$$
\partial_t T_j \approx
\frac{T_{j-2} - 6T_{j-1} + 3T_j + 2T_{j+1}}{6\Delta x}.
$$

The time continuous part of the transport equation becomes :

$\partial_t T = -i\omega T_j$, 

Therefore, $\omega = \omega_r + I\omega_i$ with 

$\omega_r = c_0 (\frac{4}{3} \sin\theta/ - \frac{1}{6} \sin2\theta )/\Delta x$

Which gives us     $c_p = \frac{\omega_r}{k} = c_0 (\frac{4}{3} \sin\theta/ - \frac{1}{6} \sin2\theta )/\theta$

And     $\omega_i = -\frac{c_0}{\Delta x}(1-\cos\theta)^2/3$

**Interpretation.** The wave is $e^{\omega_i t}e^{i(kx - \omega_r t)}$:
 
- the real part $\omega_r$ is the **same as CEN4**, so UBS has the same $c_p$ as CEN4;
- the imaginary part $\omega_i = -c_0 D/\Delta x < 0$ is a **damping** that kills short waves
  while leaving long waves almost untouched. For small $\theta$, $D \approx \theta^4/12$;
  at $\theta=\pi/2$, $D = 1/3$; at $\theta = \pi$, $D = 4/3$.
UBS is CEN4 plus a fourth-order (bi-Laplacian-like) diffusion.

## Summary

| Scheme | $c_p/c_0$ | $D$ |
|---|---|---|
| Exact | 1 | 0 |
| CEN2 | $\sin\theta/\theta$ | 0 |
| CEN4 | $(\tfrac43\sin\theta-\tfrac16\sin2\theta/)\theta$ | 0 |
| UBS | Same as CEN4 |  $- (1-\cos\theta)^2/3$ |


## Time stepping

For $C \ll 1$ the time error is far smaller than the spatial error ($\propto\theta^2$ or $\theta^4$). The time scheme matters when $C$ approaches 1. 

$C = c_0\Delta t_{out}/\Delta x $

For the simulations in the demonstrator :
| Parameter | Value |
|---|---|
| $c_0$ | $0.5 m.s^{-1}$ |
| $\Delta t_{out}$ | $3600 s$ |
| $\Delta x$ | $10000 m$ |
| $C$ | $0.18$ |


In our case the "space only" curves of the sections above are a good reference for RK3 and MLF. 

## Measuring $c_p$ from model output
 
For a linear scheme on a periodic domain, take the spatial Fourier transform of the field
at each output time:
 
$$
F_m(t) = \sum_{j} T_j(t)\, e^{-i k_m x_j}, \qquad k_m = \frac{2\pi m}{N\Delta x}, \quad \theta_m = \frac{2\pi m}{N}.
$$
 
(With `numpy.fft.rfft` the kernel is $e^{-ikx}$, so a wave $e^{i(kx-\omega t)}$ gives a
coefficient $\propto e^{-i\omega t}$.) Each mode is multiplied by the same complex factor
between two outputs separated by $\Delta t_{out}$:
 
$$
R_m = \frac{F_m(t + \Delta t_{out})}{F_m(t)} = e^{-i\omega\Delta t_{out}}
\;\Longrightarrow\;
\omega_r = -\frac{\arg R_m}{\Delta t_{out}}, \quad
\omega_i = \frac{\ln|R_m|}{\Delta t_{out}}, \quad
c_p = \frac{\omega_r}{k_m}.
$$
 
Averaging $R_m$ over all pairs of consecutive outputs, **weighted by the amplitude**
$|F_m(t)F_m(t+\Delta t_{out})|$, reduces the noise (modes with almost zero amplitude, such
as the spectral zeros of a square block, have an unreliable phase).
 
!!! warning "Phase aliasing"
    $\arg R_m$ is only defined modulo $2\pi$. The measurement is valid if the phase
    rotation between two outputs is below $\pi$:
    $k\,c_0\,\Delta t_{out} < \pi$, i.e. $\theta < \pi\Delta x/(c_0\Delta t_{out})$.
    Removing the exact advection first, by multiplying $R_m$ by $e^{+ikc_0\Delta t_{out}}$,
    relaxes this to $k\,|c_p - c_0|\,\Delta t_{out} < \pi$.
 

 
