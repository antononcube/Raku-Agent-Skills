---
name: raku-number-theory-computations
description: Write, explain, and validate Raku number-theory computations with Math::NumberTheory, including primes, factorization, modular arithmetic, divisors, continued fractions, digit representations, and Frobenius problems. Use when a task needs executable Raku code based on this package; do not use for general mathematical exposition without Raku implementation.
---

# Raku number-theory computations

Use `Math::NumberTheory` to implement focused number-theory computations in Raku. Start programs with:

```raku
use v6.d;
use Math::NumberTheory;
```

For visual or embedding utilities, load `Math::NumberTheory::Utilities` as well.

## Choose the package routine

1. Identify the mathematical operation and look it up in [the routine table](assets/sub-names-and-descriptions-table.md). The table is the supplied package capability index.
2. Before committing to an invocation, find the closest concrete example in [the local test suite](../Math-NumberTheory/t/). Use `rg -n 'routine-name' ../Math-NumberTheory/t` to locate it.
3. Preserve the tested calling convention: positional versus named arguments, listability, return shape, and numeric domain. Do not infer unsupported options or overloads merely from a routine name.
4. Return ordinary Raku code with the needed `use` statement, and show the result or verify the relevant invariant when it makes the answer clearer.

The test suite is the primary source for executable syntax. The routine table may omit routines exercised by tests, so search the tests when the table has no entry.

## Tested usage patterns

### Primes and factorization

```raku
use Math::NumberTheory;

say prime(100);                       # 541
say next-prime(32, :2k);               # 41
say factor-integer(120).Array;         # [(2, 3), (3, 1), (5, 1)]
say are-coprime(8, 11);                # True
say primitive-root-list(9);            # [2, 5]
```

`factor-integer` returns `(prime, exponent)` pairs. Reconstruct an input with `[*]` over `prime ** exponent`, as demonstrated in `t/01-integer-factors.rakutest`. Many prime routines accept a list; verify the exact list result in `t/04-prime.rakutest` before relying on that behavior.

### Modular arithmetic and congruences

```raku
use Math::NumberTheory;

say power-mod(3, -2, 7);               # 4
say modular-inverse(3, 7);             # 5
say chinese-remainder([2, 3, 5], [3, 5, 7]);  # 68
say multiplicative-order(5, 7);        # 6
```

For `chinese-remainder`, supply parallel lists of remainders and moduli. A non-coprime system can have no solution; handle its false result rather than assuming one exists. `power-mod` and `modular-inverse` are listable in the tested forms.

### Divisors, arithmetic functions, and special integers

```raku
use Math::NumberTheory;

say divisors(20);                      # (1 2 4 5 10 20)
say divisor-sigma(20, :2exponent);     # 546
say is-perfect-number(6);              # True
say abundant-number(3);                # 20
say fibonacci([2, 12, 30]);            # (1 144 832040)
```

`divisor-sigma` accepts either `(exponent, n)` or `n, :exponent(...)`. For classification predicates, non-integer input is tested to return `False`; nevertheless validate inputs when the surrounding program requires a strict domain.

### Representations and rational approximations

```raku
use Math::NumberTheory;

my @terms = continued-fraction(415 / 93);     # (4, 2, 6, 7)
say from-continued-fraction(@terms);           # 415/93
say convergents(pi, 4);                         # first four convergents
say integer-digits(34343, 16);                  # (8 6 2 7)
say powers-representations(1729, 2, 3);         # ((1 12) (9 10))
```

Use exact `Rat`/`FatRat` inputs where exact rational behavior matters. Continued fractions of floating values are approximations, so constrain the term count or tolerance and do not present a final term as universal across numeric backends.

### Linear Diophantine / Frobenius problems

```raku
use Math::NumberTheory;

my @coefficients = 12, 16, 20, 27;
my @solutions = frobenius-solve(@coefficients, 123);
say frobenius-number(|@coefficients);   # 89

for @solutions -> @x {
    die 'invalid solution' unless sum(@x <<*>> @coefficients) == 123;
}
```

`frobenius-solve` returns a list of coefficient vectors; pairwise multiply each vector with its coefficients to validate a solution. The call also supports `:coeff` and `:rhs`, as shown in `t/27-frobenius-solve.rakutest`.

## Raku conventions

- Use hyphenated package routine names exactly as exported, such as `is-prime` and `quotient-reminder`.
- Use named-argument syntax such as `:5sides`, `:2k-min`, and `:4number-of-terms` when matching tested calls.
- When applying a routine elementwise, prefer Raku's hyperoperator form when appropriate: `(100..103)».&prime`.
- Treat Raku lists and arrays deliberately: use `.Array` only when an `Array` is needed; retain lazy/list return values otherwise.
- For Gaussian-integer behavior, use the documented tested forms and verify unit-equivalent GCD/LCM results by an invariant rather than expecting one canonical associate.

## Validation

For a standalone example, run it with `raku path/to/file.raku`. For a package behavior claim, run the narrow existing test when its dependencies are available, for example:

```sh
raku Math-NumberTheory/t/02-power-mod.rakutest
```

If the local package is not installed or discoverable, state that environmental limitation rather than replacing package calls with an unrelated implementation.
