# Advection of a salt block

Track, for several salinity levels $S-35$, the position of the front over time
and fit $x = x_0 + c\,t$. Differences between levels signal dispersion.

## Tips

- Work with **unwrapped** positions (follow the block in a window moving at $c_0$,
  index the field modulo `nx`) so the regression uses all output times.
- Plot the **deviation from $c_0 t$**: propagation at $c_0$ is a horizontal line
  and the slope of each level is $c - c_0$.
- A tolerance on the level (`abs(f - level) <= tol`) must stay below half the
  level spacing.

Add your analysis script or notebook here.
