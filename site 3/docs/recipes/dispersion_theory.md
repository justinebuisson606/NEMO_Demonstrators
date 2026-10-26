# Numerical dispersion: theory

We consider $\partial_t T + c_0 \partial_x T = 0$ with uniform $c_0$, a periodic
domain, and a linear scheme. A square block is a sum of sinusoids, each evolving
independently.

Insert $T_j = e^{i(jk\Delta x - \omega t)}$ and set $\theta = k\Delta x$.
The spatial scheme gives $\omega \Delta x / c_0 = S(\theta)$ (complex for dissipative schemes).

| Scheme | $S(\theta)$ | $c_p/c_0$ | $c_g/c_0$ |
|---|---|---|---|
| Exact | $\theta$ | 1 | 1 |
| CEN2 | $\sin\theta$ | $\sin\theta/\theta$ | $\cos\theta$ |
| CEN4 | $\tfrac43\sin\theta-\tfrac16\sin2\theta$ | $S/\theta$ | $\tfrac43\cos\theta-\tfrac13\cos2\theta$ |
| UBS | CEN4 $- i(1-\cos\theta)^2/3$ | same as CEN4 | same as CEN4 |

with

$$
c_p = \frac{\omega_r}{k}, \qquad c_g = \frac{d\omega_r}{dk} = c_p + k\frac{dc_p}{dk}.
$$

For small $\theta$: CEN2 $c_p/c_0 \approx 1-\theta^2/6$, CEN4 $c_p/c_0 \approx 1-\theta^4/30$.
UBS damping: $\omega_i \Delta x/c_0 = -(1-\cos\theta)^2/3$.

## Time stepping

With $C = c_0\Delta t/\Delta x$ and $y = C\,S(\theta)$:

- RK3: $G = 1 + z + z^2/2 + z^3/6$ with $z=-iy$, so $c_p/c_0 = -\arg G/(C\theta)$.
- Leapfrog: $c_p/c_0 = \arcsin(y)/(C\theta)$.

For $C \ll 1$ the time-stepping error is negligible against the spatial one.

## Measuring $c_p$ from model output

For each wavenumber, the ratio of Fourier coefficients between two outputs is
$e^{-i\omega\Delta t_{out}}$: its argument gives the phase rotation, its modulus the damping.

!!! note "Validity"
    Linear schemes only (so not FCT), uniform current, periodic domain, and
    $k\,|c_p-c_0|\,\Delta t_{out} < \pi$.
