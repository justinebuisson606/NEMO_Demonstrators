# Configuration of the simulations 



## Summary table of the configuration parameters (NEMO 5.0)

| Parameter | Value |
|---|---|
| **Domain and grid** | |
| Configuration | `CANAL`: zonal channel, flat bottom (`nn_botcase = 0`) |
| Depth $L_z$ | 1000 m |
| Resolution | $\Delta x = \Delta y = 10$ or $5$ km, $\Delta z = 1000$ m (single vertical level) |
| Boundary conditions | periodic in $x$ (`ln_Iperio`), not periodic in $y$ (except for diagonal advection)|
| Coriolis | $f$-plane, $f_0$ |
| Wind forcing | none (`rn_u10 = 0`) |
| **Time stepping and outputs** | |
| Model time step | $\Delta t = 900$ s (leapfrog, MLF)|
| Duration | 7680 steps = 80 days |
| Courant number | $C = c_0\Delta t/\Delta x = 0.045$ (MLF)|
| Output frequency | 1 day ($\Delta t_{out} =$ 1d or 1h)|
| Output variables | `soce`, `sssgrad`, `salt2c` |

| **Initial conditions** | | | | |
|---|---|---|---|---|
| Subcases | 1-directional block of salt | 2-directional block of salt | sinusoidal salt distribution | Eddies |
| Current | uniform and zonal, $u = c_0 = 0.5$ m s⁻¹, over the whole domain | uniform and zonal, $u = c_0 = 0.5$ m s⁻¹, over the whole domain | uniform and zonal, $u = c_0 = 0.5$ m s⁻¹, over the whole domain  | uniform and zonal, for $y > 0, u = c_0 = 0.5$ m s⁻¹ $y < 0, u = c_0 = -0.5$ m s⁻¹ |
| Initial salinity distribution | background 30 psu, block at 35 psu, `rn_salszx` × `rn_salszy` = 250 km × 250 km | background 30 psu, block at 35 psu, `rn_salszx` × `rn_salszy` = 250 km × 250 km | A sinusoidal distribution along the x-axis,  $S(x,y,z,0) = 30 + sin(\frac {f 2 \pi x}{L_x}) psu$ |for $y > 0, S(x,y,z,0) = 31 psu$ $y < 0, S(x,y,z,0) = 29 psu$ |
| SSH noise | none (`ln_sshnoise = .false.`) | none (`ln_sshnoise = .false.`) | none (`ln_sshnoise = .false.`) | random noise, $S +\epsilon$ (`ln_sshnoise = .true.`) |


## Advection schemes compared

| Run | Scheme | NEMO switches |
|---|---|---|
| `cen2` | 2nd-order centred | `ln_traadv_cen`, `nn_cen_h = nn_cen_v = 2` |
| `cen4` | 4th-order centred | `ln_traadv_cen`, `nn_cen_h = nn_cen_v = 4` |
| `ubs` | Upstream-biased (3rd order) | `ln_traadv_ubs` |
| `fct2` | Flux-corrected, 2nd order | `ln_traadv_fct`, `nn_fct_h = nn_fct_v = 2` |
| `fct4` | Flux-corrected, 4th order | `ln_traadv_fct`, `nn_fct_h = nn_fct_v = 4` |
| reference | advection off | `traadvOFF` run, block translated at $c_0$ |
