---
name: raku-l10n-localizations
description: Create, extend, or validate Raku L10N slang localizations and their .l10n translation tables. Use for localized Raku keywords, routines, operators, named arguments, executors, or deparsing; not for translating program output or error messages.
---

# Raku L10N localizations

Build natural-language Raku localizations with the L10N translation-table
workflow. A localization is an input slang plus a matching deparser: it
parses localized Raku into the ordinary Raku AST, and can deparse that AST
back into the localized spelling. It does not make a separate runtime or
translate a program's output and diagnostics.

## Start from the supplied table

Read both supplied tables before adding, changing, or reviewing a table:

- [references/RU.l10n](references/RU.l10n) is the key inventory: it contains
  all 645 L10N keys, with 405 active Russian mappings and 240 intentionally
  untranslated entries retained as commented mappings. Use it to determine
  whether a key exists and to preserve deliberate English spellings.
- [references/BG.l10n](references/BG.l10n) is a compact, working Bulgarian
  table with the same 405 active mappings. Use it to compare an active-only
  table and see the supported key families at a glance.

Each non-comment mapping is whitespace-separated:

```text
# KEY          TRANSLATION
block-if       ако
core-say       кажи
named-encoding кодировка
```

- Keep keys exactly as defined by L10N; translate only their values. Preserve
  comments, blank lines, and grouping headings so the table remains reviewable.
- A line such as `#quote-lang-q q` is a disabled mapping, not a heading: it
  explicitly leaves that key in English. Retain it as a record of the
  decision; remove only its leading `#` to enable a considered translation.
- Use valid Raku identifier/operator spelling appropriate to the token's role.
  Preserve Unicode exactly and save the table as UTF-8.
- An absent or disabled mapping is deliberately English, not an error. Do not
  force translations for quote languages, single-letter regex adverbs, system
  hooks, meta-operators, or mathematical names merely for coverage.
- Treat a translated spelling as reserved for that token category. Do not
  suggest it for users' own routines, methods, or named arguments: a call to
  that spelling is rewritten to the underlying Raku name.

## Choose the right key family

Use the source table's existing grouping and key names as the authority.
Common families include:

| Need                          | Key family / examples                                    |
|-------------------------------|----------------------------------------------------------|
| Control constructs            | `block-if`, `block-for`, `modifier-while`                |
| Built-in routines and methods | `core-say`, `core-map`, `core-elems`                     |
| Word operators                | `infix-and`, `infix-eq`, `prefix-not`                    |
| Declarations                  | `scope-my`, `package-class`, `routine-method`            |
| Traits and statement prefixes | `trait-is-rw`, `traitmod-is`, `stmt-prefix-try`          |
| Named arguments and adverbs   | `named-encoding`, `named-delete`, `adverb-rx-exhaustive` |
| Compile-time and import words | `phaser-ENTER`, `pragma-strict`, `use-use`               |

Use separate `block-*` and `modifier-*` entries even when the localized word
is identical. Check nearby semantic entries before assigning short forms; in
particular, a spelling can collide across named arguments, adverbs, and core
routine names.

## Editing and generation workflow

1. Make the smallest table change that expresses the requested language
   decision. Keep intentionally untranslated entries untouched.
2. From the localization distribution root (not a parent monorepo), run
   `update-localization`. This generates both the slang module and
   `RakuAST::Deparse::L10N::<LANG>` from the one table and precompiles the
   generated slang. Run the generator with Rakudo: Raku++ can run generated
   modules but cannot load L10N to generate them.
3. Test both directions. Parse a localized snippet and deparse it with the
   language code; also confirm the normal deparse remains English:

```raku
my $ast := Q[моя $х = 1].AST("BG");
say $ast.DEPARSE("BG");  # моя $х = 1
say $ast.DEPARSE;        # my $х = 1
```

4. Compile and run representative localized source containing each edited
   category. Check naming collisions as well as simple parsing.

Do not hand-edit generated `lib/` output when a table change is intended;
regenerate it so the slang and deparser stay aligned.

## Running localized code

There are two mutually exclusive entry modes:

- A program beginning with English `use L10N::<LANG>;` must be run directly
  with `raku`; the `use` line is necessarily English because the slang is not
  active until that line has compiled.
- The localization's installed executor loads the slang before parsing the
  file. In that mode the whole file, including its import word, is localized;
  it must not contain the English `use L10N::<LANG>;` line.

Use `use L10N::<LANG> 'no-slangification'` for tools or tests that need the
roles but must keep their own source in ordinary Raku.

## Compatibility and variants

Document engine-specific behavior separately from language decisions. For
current L10N behavior, test generation under Rakudo and test localized source
under every engine the package supports. Some Rakudo versions need
`RAKUDO_RAKUAST=1` for slang parsing; executors may set it automatically.

L10N tables can express alternate accepted spellings with `|`, with the first
spelling used for deparsing. Use this only after testing the target engines:
the Bulgarian package documents generator and Raku++ limitations for token
alternations. Prefer one stable citation form when compatibility is required.

## Scope boundary

L10N translates grammar input and AST deparsing only. Do not represent
localized errors, `.gist` output, print output such as `True`, or runtime
library text as supported by the translation table. Treat those as separate
localization projects.

## Dedicated executables

- `bulku` is the Bulgarian-localized Raku code executor.
- `rusku` is the Russian-localized Raku code executor. 
- `bulku` and `rusku` re-run the interpreter that invoked it with `-ML10N::BG` and `-ML10N::RU` respectively.
  - So the slang is in place before the file is parsed and a program needs no `use` line of its own.
- The two ways of running a localized program are exclusive. 
  - Under `bulku` the file is Bulgarian from its first character, `use` included — it is spelled `използвай` there.