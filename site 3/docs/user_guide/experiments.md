# Experiments

## Salt block advection

| Parameter | Value |
|---|---|
| Background salinity | 30 psu |
| Block salinity | 35 psu |
| Current | uniform, zonal, $c_0 = 0.5\ \mathrm{m\,s^{-1}}$ |
| Grid spacing | $\Delta x$ = 5 or 10 km (adapt to your run) |
| Domain | periodic in x |
| Advection schemes | CEN2, CEN4, UBS, FCT2, FCT4 |
| Time stepping | RK3 or MLF |
| Outputs | `soce`, `sssgrad` (check output frequency in `time_counter`) |

!!! warning
    `dt` in the analysis is the interval **between outputs**, not the model
    time step. It sets the maximum measurable wavenumber
    $\theta < \pi \Delta x / (c_0 \Delta t_{out})$.
