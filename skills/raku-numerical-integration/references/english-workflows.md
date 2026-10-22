# DSL::English::IntegrationWorkflows

`ToIntegrationWorkflowCode` parses an English integration command and renders
code for a selected target. Its default target is `WL-System`; pass
`'Raku::Ecosystem'` (or `'Raku'`) when the requested output is Raku.

```raku
use DSL::English::IntegrationWorkflows;

my $command = 'integrate numerically exp(-(x^2 + y^2)) over the domain [-Inf, Inf] x [-Inf, Inf] using unit cube rescaling';
my $raku = ToIntegrationWorkflowCode($command, 'Raku::Ecosystem');
say $raku;
```

This renders a `nintegrate` call. Generated Raku code does not insert the
`use Math::NIntegrate;` import, so add it where the code will run.

## Supported Raku-oriented examples

```raku
ToIntegrationWorkflowCode(
    'integrate 1/x^2 over [1,2] with local adaptive and precision goal 5',
    'Raku::Ecosystem',
)
# nintegrate({1/$^x **2}, ['x',1,2], method => "local-adaptive", precision-goal => 5)

ToIntegrationWorkflowCode(
    'integrate 1/sqrt(x) over [0,1] without singularity handling with up to 20 recursion levels',
    'Raku::Ecosystem',
)
# nintegrate({1/sqrt($^x)}, ['x',0,1], singularity-handler => "none", max-recursion => 20)
```

The grammar recognizes common formulations for numerical integration,
one-dimensional ranges, rectangular domains, method names, precision or
accuracy goals, recursion levels, and “without singularity handling.” It
attempts fuzzy matching and may emit warnings for misspellings. Correct the
command and translate again rather than treating a warning as confirmation.

## Review before execution

The Raku renderer infers variable names from letters in the integrand and does
simple substitutions (`^` to `**`, and familiar `Sin[...]`, `Cos[...]`,
`Exp[...]`, `Log[...]`, `Sqrt[...]` forms). Inspect the result especially for
multi-letter identifiers, function names, LaTeX, Mathematica syntax, and
implicit variables.

Current package limitations include:

- Symbolic integration is not a Raku execution workflow.
- Functional boundaries are not parsed into Raku calls.
- Method parsing is shallow; use direct `Math::NIntegrate` syntax for nested
  strategies/rules and detailed rule options.
- LaTeX and Mathematica integrands do not have a general reliable Raku
  conversion path.

Never evaluate generated code from untrusted natural-language input with
`EVAL`. For a trusted, reviewed command, prefer placing the generated call in
a normal Raku source file and running it with the required imports. If dynamic
evaluation is deliberately needed, scope it tightly and use
`use MONKEY-SEE-NO-EVAL;` only after review.
