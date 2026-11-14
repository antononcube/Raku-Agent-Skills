---
name: raku-functional-parsers
description: Implement token- or character-based Raku parser combinators with FunctionalParsers, or specify EBNF grammars and generate FunctionalParsers/Raku parser code. Use for `FunctionalParsers`, `fp-ebnf-parse`, EBNF targets, grammar diagrams, and random sentence generation; not for ordinary Raku regex or grammar-only work.
---

# Build parsers with FunctionalParsers

Use `FunctionalParsers` when the requested parser benefits from explicit combinators, backtracking over words or tokens, simple list-shaped syntax trees, or an EBNF specification that can be transformed into Raku artifacts. Start with the smallest grammar and make the input representation explicit: word-oriented parsers normally receive `.words`, while character-oriented work normally receives `.comb` or another character list.

## Direct functional parsers

Import the public combinators with `use FunctionalParsers :ALL;`. Build named, small parsers before composing them:

- Use `symbol` for an exact token and `satisfy` for a predicate over the next token.
- Use `token` for an exact sequence of characters; use `drop-spaces` (or `sp`) when a character parser must skip leading whitespace.
- Use `sequence` or `«&»` for an ordered sequence. `alternatives` or `«|»` retains the parse results from every branch; use `alternatives-first-match` or `«||»` only when declaration-order choice is intended, because it stops at the first branch that consumes input.
- Use `apply` (or its infix form) to turn a parsed value into the desired AST value. Remember that the n-ary `⨀` form places the function first, unlike `(^)` and `«o`.
- Use `many` and `option` for repetition and optional parts. Keep repetitions able to consume input; a repetition of a zero-width/always-successful parser can fail to terminate or yield surprising parses.

Call a parser with a token list and inspect both the value and the remaining input. A successful prefix is not necessarily a complete parse: wrap it in `just` when the task requires full consumption. When several valid parses are possible, select intentionally and include ambiguity cases in tests. In the installed implementation, `shortest` selects the result with the least remaining input (the parse that consumed the most); verify that behavior against the package version when it matters.

For the full direct-parser inventory, signatures, operators, and shortcuts, read [references/Parsers-documentation.md](references/Parsers-documentation.md). Do not load it solely for ordinary `symbol`/`sequence`/`alternatives` work.

For multiword dictionary terms, read [references/lookup-parsings.raku](references/lookup-parsings.raku). It shows a `lookup-satisfy` parser that consumes a fixed number of words, maps them through a dictionary, and combines alternatives and sequences.

## EBNF-driven parsers

Import EBNF support separately:

```raku
use FunctionalParsers::EBNF;
```

Represent grammar rules with angle-bracketed nonterminals and a terminating semicolon. Use quoted literals for terminals, `|` for alternatives, `,` for sequences, `{ ... }` for repetition, `[ ... ]` for optional constructs, and `( ... )` for grouping. The package also supports `<&` and `&>` for left- and right-picking sequences; use these only when the resulting AST should discard one side. Do not silently replace those operators with commas: that changes the parse value.

`fp-ebnf-parse` is itself a functional parser and expects a positional character input in the installed package; call it as `fp-ebnf-parse($ebnf.comb, target => 'Raku::AST')` unless the installed version demonstrates string input. Inspect its result before evaluating generated output. Choose a target deliberately: `Raku::AST` to inspect the interpreted grammar, `Raku::Code` for FunctionalParsers definitions, `Raku::Class` or `Raku::Grammar` for Raku parser artifacts, and `MermaidJS::Graph` for a grammar diagram. Target/action naming varies across package examples (`target => ...` and `actions => ...`); consult the installed package version and the supplied examples before committing generated code.

Generated code is code generation, not validation. Show it first, compile it, and evaluate it only when the grammar is trusted and the user has asked for runnable output. Likewise, use `fp-random-sentence(..., :!eval)` to inspect random-generation code without evaluation; use `:eval` only for trusted generated code. Pass `:restrict-recursion` for recursive grammars to avoid unbounded generation.

Read [references/FunctionalParsers-README.md](references/FunctionalParsers-README.md) for package-level EBNF, code-generation, CLI, and Mermaid examples. Read the focused examples only when applicable:

- [references/ebnf-with-side-picks.raku](references/ebnf-with-side-picks.raku) for `<&`/`&>` semantics and `Raku::AST`, `Raku::Class`, `Raku::Code`, and `Raku::Grammar` outputs.
- [references/ebnf-random-sentences.raku](references/ebnf-random-sentences.raku) for style normalization, grammar display, and safe random-sentence generation.

## Deliver and verify

State the accepted input representation, whether a full parse is required, and the intended AST/output shape. Provide a minimal accepted input, a rejected input, and—where alternatives overlap—an ambiguity case. Compile the Raku program and run those cases when the package and its dependencies are available. Do not install packages, evaluate generated code, open rendered diagrams, or invoke the EBNF CLI unless that action is requested or otherwise authorized.
