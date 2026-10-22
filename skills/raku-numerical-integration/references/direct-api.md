# Math::NIntegrate direct API

Import the package and call `nintegrate` with a callable plus one or more
ranges. A range is a list beginning with a string variable name; the callable
parameters and the range names must agree.

```raku
use Math::NIntegrate;

my %result = nintegrate(
    -> $x, $y { $x + $y ** 2 },
    <x 0 2>,
    <y 0 12>,
    :pairs,
);
# %result has: integral, error, region-count
```

## Range forms

```raku
<x 0 1>                 # finite one-dimensional interval
['x', -Inf, Inf]        # improper interval
<x -Inf 0 Inf>          # an interior breakpoint at 0
['y', 0, { $^x.sqrt }]  # functional upper boundary (direct API)
```

For a functional boundary, the function may use previously introduced range
variables. This feature is a direct `Math::NIntegrate` capability, not a
current English-DSL translation feature.

## Result, goals, and precision

```raku
my %result = nintegrate(
    -> $x { exp(-$x ** 2) },
    <x 0 Inf>,
    working-precision => Rat,
    precision-goal => 8,
    accuracy-goal => 8,
    max-recursion => 20,
    :pairs,
);
```

`precision-goal` determines relative tolerance (`10 ** -precision-goal`);
`accuracy-goal` determines absolute tolerance. Default working precision is
`Num`; `Rat` and `FatRat` are accepted alternatives. Defaults include a
precision goal of 6 for ordinary methods and `max-recursion` 12. A result can
still fail to converge, so inspect errors and perform a stability check.

## Method specifications

Simple forms:

```raku
method => 'global-adaptive'       # default when omitted
method => 'local-adaptive'
method => 'double-exponential'
method => 'gauss-kronrod-rule'
method => 'unit-cube-rescaling'
```

Nested forms use `method =>` inside a list. The parser supports equivalent
PascalCase class-style names such as `GlobalAdaptive` and `GaussKronrodRule`.

```raku
method => (
    'unit-cube-rescaling',
    method => ('gauss-kronrod-rule', :7points),
)

method => (
    'cartesian-rule',
    method => (
        ('gauss-kronrod-rule', :5points),
        ('trapezoidal-rule', :10points),
    ),
)
```

`unit-cube-rescaling` can wrap a strategy or rule; a missing strategy is
completed with global adaptive behavior. For multidimensional input, a single
one-dimensional rule is automatically promoted through a Cartesian rule. Do
not attach a meaningful nested rule to `double-exponential`: its strategy
ignores the rule specification.

Available strategy names include `global-adaptive`, `local-adaptive`,
`double-exponential`, `monte-carlo`, `quasi-monte-carlo`,
`adaptive-monte-carlo`, and `adaptive-quasi-monte-carlo`. Rule names include
`trapezoidal-rule`, `newton-cotes-rule`, `gauss-kronrod-rule`,
`clenshaw-curtis-rule`, `monte-carlo-rule`, `multidimensional-rule`,
`double-exponential-rule`, and `cartesian-rule`.

## Difficult integrals

- For endpoint singularities such as `1 / sqrt(x)` on `[0, 1]`, try
  `double-exponential` and validate against the known value when possible.
- For infinite limits, write `Inf`/`-Inf` explicitly. Consider
  `double-exponential` in 1D or `unit-cube-rescaling` for higher dimensions.
- For point discontinuities or singularities, include an interior breakpoint
  in the range so the integrator sees the partition, and adjust the
  singularity handler only with a reason.
- If convergence fails, first examine whether the integral exists and whether
  the discontinuity or singularity was represented correctly. Then increase
  `max-recursion` or choose a suitable method; do not report an unconverged
  approximation as a confirmed result.

## CLI

The installed package also provides `nintegrate`:

```sh
nintegrate '{$^x + $^y}' '<x 0 1>' '<y 0 10>' --pairs
```

Quote shell arguments so that the shell does not expand Raku syntax. Use
`nintegrate --help` for the installed CLI's exact option parsing.
