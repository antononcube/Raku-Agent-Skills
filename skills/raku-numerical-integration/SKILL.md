---
name: raku-numerical-integration
description: Create, translate, validate, and troubleshoot numerical-integration workflows in Raku with Math::NIntegrate and DSL::English::IntegrationWorkflows. Use for executable Raku integrations, method selection, error estimates, multidimensional or improper integrals, and English integration commands; do not use for purely symbolic calculus without a numerical Raku workflow.
---

# Raku numerical integration

Use `Math::NIntegrate` for executable numerical integration. Use
`DSL::English::IntegrationWorkflows` only when an English command should be
translated to code; it generates a limited subset of Raku and needs review
before execution.

```raku
use Math::NIntegrate;

my %result = nintegrate(
    -> $x { 1 / $x.sqrt },
    <x 0 1>,
    method => 'double-exponential',
    :pairs,
);
say %result<integral>;
say %result<error>;
```

Begin with a small, explicit `nintegrate` call. State the integrand, every
range, any known singularities or infinite limits, desired accuracy, and an
independent check when one is available. Use `:pairs` when reporting a result:
it returns a map with `integral`, `error`, and `region-count`; without it,
`nintegrate` returns only the integral estimate.

## Direct Math::NIntegrate workflows

Ranges follow the integrand argument order and use a variable name plus lower
and upper bounds: `<x 0 1>`, `['x', 0, Inf]`, and one range per dimension.
Use a callable whose parameters correspond to those range names. `Inf` and
`-Inf` are supported; extra values between the endpoints define interior
breakpoints.

Start with the default global-adaptive method for ordinary bounded problems.
Choose a method deliberately when the integrand gives useful evidence:

- Use `double-exponential` for a one-dimensional endpoint singularity or an
  improper one-dimensional integral.
- Use `unit-cube-rescaling` for integrals with infinite bounds, including
  multidimensional ones; it can wrap another method.
- Use `local-adaptive` when local refinement is wanted.
- Use `monte-carlo`, `quasi-monte-carlo`, or their adaptive variants for an
  appropriate higher-dimensional or stochastic workflow; communicate their
  seed, sampling controls, and uncertainty rather than implying deterministic
  precision.
- Specify a rule or nested method only when it is material to the request.
  For multiple dimensions, a one-dimensional rule such as
  `gauss-kronrod-rule` is automatically used through a Cartesian rule.

Use the package's hyphenated method names or its documented PascalCase forms;
do not invent method names or nesting. Pass numerical controls as normal Raku
named arguments, e.g. `precision-goal => 8`, `accuracy-goal => 8`,
`max-recursion => 20`, `min-recursion => 1`, and `working-precision => Rat`.
The default maximum recursion is 12 and default precision goal is normally 6,
so specify goals for results that need a stated tolerance. Precision and
accuracy goals must be positive; `min-recursion` cannot exceed
`max-recursion`.

Read [direct-api.md](references/direct-api.md) when writing a nontrivial
`nintegrate` call, selecting nested methods, handling improper ranges, or
diagnosing convergence.

## English integration-workflow commands

Translate a command to Raku with an explicit target:

```raku
use DSL::English::IntegrationWorkflows;

my $command = 'integrate 1/x^2 over [1,2] with local adaptive and precision goal 5';
my $code = ToIntegrationWorkflowCode($command, 'Raku::Ecosystem');
say $code;
```

Then inspect the generated text, add `use Math::NIntegrate;`, and run the
reviewed call normally. Do not apply `EVAL` to command text that is untrusted
or has not been reviewed. The default target is Wolfram Language, not Raku.

The translator currently handles basic bounded and rectangular domains,
common methods, goals, recursion limits, and disabling singularity handling.
It does **not** provide reliable Raku translation for symbolic integration,
functional boundaries, nested method options, or arbitrary LaTeX/Mathematica
integrands. For any of those, write or repair the `nintegrate` call directly.
Read [english-workflows.md](references/english-workflows.md) when translating
or debugging English commands.

## Validate the numerical result

Treat a numerical answer as an estimate, not just a printed scalar:

1. Request `:pairs` and compare `error` with the required tolerance.
2. Re-run with a tighter `precision-goal`, more recursion, or a justified
   alternative method; the estimates should stabilize.
3. Check a known exact value, symmetry, scale, or a simpler limiting case when
   available.
4. For a multidimensional or stochastic computation, disclose dimension,
   method, controls, and reproducibility inputs such as `random-seed`.

Run a standalone example with `raku path/to/example.raku`. If either package
is unavailable, install the explicitly requested dependency with `zef install
Math::NIntegrate` and/or `zef install DSL::English::IntegrationWorkflows`, or
state that it is not available rather than silently substituting another
numerical library.
