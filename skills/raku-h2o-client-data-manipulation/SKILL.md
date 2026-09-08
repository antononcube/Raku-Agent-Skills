---
name: raku-h2o-client-data-manipulation
description: Import, upload, parse, and transform H2O data frames with the Raku H2O::Client, including Rapids filtering, grouping, and type conversion.
---

# Raku H2O Client data manipulation

Use this skill when working with tabular data in an H2O cluster through
`H2O::Client`. A `Frame` is a handle to data stored in H2O; parsing and
materializing transformations happen on the server.

## Import and upload

Create a client, then choose the ingestion method based on where the source is
reachable:

```raku
use H2O::Client;

my $h2o = H2O::Client.new('http://127.0.0.1:54321');
```

- Use `import-file($url-or-server-path, :job, ...)` when the H2O server can
  reach the URL or filesystem path. With `:job`, it imports, obtains inferred
  parse setup, and submits a parse job. Wait for it before using its frame.

  ```raku
  my $frame = $h2o.import-file(
      'https://example.test/data/sales.csv',
      :job,
      destination-frame => 'sales.hex',
      column-names => <region date revenue>,
      check_header => 1,
  ).wait.result;
  ```

  Without `:job`, `import-file` only returns H2O's `ImportFiles` response; it
  does not create a parsed frame. Pass parse options such as `check_header`,
  `separator`, `column-names`, or `column-types` alongside `:job` when the
  inferred setup needs adjustment.

- Use `upload-file($local-path.IO, ...)` for a file on the Raku process's local
  OS filesystem, especially when it is not mounted on the H2O server. It posts
  the file to `/3/PostFile`, parses it, and returns a job.

  ```raku
  my $frame = $h2o.upload-file(
      'resources/allyears2k_headers.csv'.IO,
      destination-frame => 'airlines.hex',
      check_header => 1,
  ).wait.result;
  ```

- Use `upload(@records, ...)` for in-memory Raku records. It serializes the
  records to a temporary CSV, uploads it, and parses it. It returns a job.

  ```raku
  my $frame = $h2o.upload(
      [%(name => 'Ada', age => 37), %(name => 'Lin', age => 16)],
      destination-frame => 'people.hex',
  ).wait.result;
  ```

`data-import` dispatches to the corresponding method for an array of records,
an `IO::Path`, or a server path string. Prefer the explicit methods when it is
important to make the source location clear.

## Build and run Rapids expressions

Frame transformations are lazy: start with `.expression`, compose operations,
then use `.materialize('destination.hex')` to create a result frame. Use
`.evaluate` only when the raw Rapids response is wanted. Close a long-lived
client with `$h2o.close` to release its lazy-created Rapids session.

```raku
my $adjusted = $frame.expression.col('revenue').multiply(1.05);
my $revenue = $adjusted.materialize('adjusted-revenue.hex');
```

The expression API supports `col`, `select`, arithmetic (`add`, `subtract`,
`multiply`, `divide`, `modulo`), comparisons, boolean `and`/`or`/`not`,
`cbind`, `rbind`, `sum`, and `mean`. Keep expressions associated with one
client; expressions from different clients cannot be combined.

## Filter rows

Build a predicate from a column expression and give it to `where`. Combine
predicates with `and`, `or`, and `not` as needed.

```raku
my $adults = $frame
    .where($frame<age>.expression.greater-or-equal(18))
    .select(<name age>)
    .materialize('adults.hex');
```

Available comparisons are `equal`, `not-equal`, `greater-than`,
`greater-or-equal`, `less-than`, and `less-or-equal`.

## Group rows

`group-by` returns a lazy builder. Select at least one aggregation before
evaluating or materializing it. Named columns are resolved from frame metadata;
numeric zero-based column indexes also work.

```raku
my $summary = $frame.expression
    .group-by(<region year>)
    .count
    .mean('revenue')
    .sum('revenue', :na<ignore>)
    .materialize('revenue-by-region-year.hex');
```

Use `count`, `mean`, `sum`, `min`, or `max`; each aggregation accepts a column
name, index, or (except `count`) `Whatever` to aggregate every non-grouping
column. Set `:na<all>`, `:na<ignore>`, or `:na<rm>` when needed.

## Convert column types

Factor conversion is wrapped by the client and produces a one-column lazy
expression:

```raku
my $regions = $frame<region>.as-factor.materialize('region-factor.hex');
```

The current wrapper does not expose date or string-to-number conversion.
For those H2O Rapids operations, construct an `Expr` with a fixed, trusted AST
and JSON-encode dynamic string literals. Do not interpolate untrusted column
names, format strings, or frame keys into an AST.

```raku
use JSON::Fast;
use H2O::Client::Rapids::Expr;

sub rapids-expr($client, Str:D $ast) {
    H2O::Client::Rapids::Expr.new(:$client, :$ast)
}

my $date = rapids-expr($h2o,
    '(as.Date (cols sales.hex ' ~ to-json('date') ~ ') ' ~ to-json('%Y-%m-%d') ~ ')'
).materialize('date-column.hex');

my $numeric = rapids-expr($h2o,
    '(as.numeric (cols sales.hex ' ~ to-json('revenue_text') ~ '))'
).materialize('revenue-numeric.hex');
```

These conversions materialize a converted column as its own frame. If a
workflow needs replacement or a multi-column output, compose the required
Rapids AST deliberately and materialize it under a new frame key; do not
silently mutate the input frame.

For implementation-level behavior and exact mocked request shapes, see
[`t/05-import-file.rakutest`](../../../Raku-H2O-Client/t/05-import-file.rakutest) and
[`t/04-rapids.rakutest`](../../../Raku-H2O-Client/t/04-rapids.rakutest).
