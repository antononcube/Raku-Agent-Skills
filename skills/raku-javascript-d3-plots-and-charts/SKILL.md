---
name: raku-javascript-d3-plots-and-charts
description: Create Raku plots, charts, diagrams, and standalone HTML visualizations with JavaScript::D3. Use when code should call the package's js-d3-* routines or prepare D3 output for a Raku Jupyter notebook; do not use for plots rendered by another Raku graphics package.
---

# JavaScript::D3 plots and charts in Raku

Use `JavaScript::D3` to generate D3 JavaScript from Raku data. The routines return code or HTML; a browser or Jupyter frontend renders the graphic. Begin ordinary programs and notebook Raku cells with:

```raku
use JavaScript::D3;
```

## Select output deliberately

The default `:format` is `jupyter`. In a Raku Jupyter notebook, first evaluate `js-d3-config` in a `%% javascript` cell to load D3 (and d3-3d by default), then emit the Raku plot code from a `%% js` cell. The configuration must be rerun for a new browser kernel/session.

```javascript
%% javascript
// Paste the output of this Raku expression here:
// js-d3-config
```

```raku
%% js
use JavaScript::D3;
js-d3-bar-chart([12, 19, 3, 5, 2], :title<Counts>)
```

`js-d3-config` returns JavaScript as a string; it does not itself display a plot. Its useful named arguments are `:d3-version`, `:d33d-version`, `:direct`, and `:with-d33d`. Keep its returned text intact when placing it in the JavaScript cell.

For a self-contained document, request HTML and write the returned string to a file. The HTML loads D3 from a CDN, so viewing it requires network access unless the generated references are changed separately.

```raku
use JavaScript::D3;

my $html = js-d3-histogram(
    [4, 7, 7, 9, 12, 13, 18],
    :number-of-bins(4),
    :title<Distribution>,
    :format<html>,
    :div-id<distribution>
);
spurt 'distribution.html', $html;
```

Use `:format<html-md>` (also accepted as `html-markdown`, `html-embedded`, or `html-fragment`) only when embedding a fragment in an existing HTML/Markdown host. Use `:format<asis>` only when the caller will provide the wrapper and execution environment. Pass a stable, unique `:div-id` for multiple HTML visualizations or an embedded target.

## Choose a routine and data shape

Read [references/sub.json](references/sub.json) first for a compact map of the supplied API. It groups routines by purpose and records the primary data shape and consequential options. For the exact overloads, aliases, types, defaults, and less-common options, read [references/subs.json](references/subs.json). Do not infer a data schema or named option merely from a routine name.

Prefer the documented simple forms where they fit:

```raku
js-d3-list-line-plot([3, 1, 4, 1, 5], :title<Sequence>);
js-d3-bar-chart({ apples => 12, pears => 9 }, :horizontal);
js-d3-bubble-chart([
    { x => 1, y => 4, z => 10, group => 'A' },
    { x => 3, y => 2, z => 20, group => 'B' }
], :tooltip, :axes);
js-d3-heatmap-plot([
    { x => 'Mon', y => 'AM', value => 4 },
    { x => 'Tue', y => 'AM', value => 9 }
], :color-palette<Inferno>);
```

For record-oriented data, use the field names shown by the selected routine's signature: for example, grouped box plots default to `group` and `value`; bubble charts use `x`, `y`, and `z`; density charts use `x` and `y`. Specify the corresponding `:group-column-name` or `:value-column-name` aliases when the input records use different names.

## Styling and validation

- Use `:title` (`:plot-label`), `:x-axis-label` (`:x-label`), and `:y-axis-label` (`:y-label`) aliases where the selected signature declares them. Do not assume every routine supports every decoration.
- Common layout controls include `:width`, `:height`, `:margins`, `:background`, `:grid-lines`, and `:div-id`; color-option names differ by routine (`:color`, `:fill-color`, `:stroke-color`, or `:color-palette`).
- Keep data as Raku numerics, pairs, lists, or `Map` records matching an overload. Materialize a lazy sequence only if the consuming routine requires it.
- For time series, use `js-d3-date-list-plot` and set `:time-parse-spec` whenever date strings do not use `%Y-%m-%d`.
- For graphs, set `:directed`/`:directed-edges` and use `:vertex-coordinates` only when coordinates are intentional; otherwise the routine can use its force configuration.
- Validate generated output at the boundary: ensure the `jupyter` form is sent to the appropriate `%% js` cell after priming, or check that `:format<html>` starts with a complete HTML document before saving it. Do not claim a visual rendering was verified unless a browser/frontend actually rendered it.

The package output contains JavaScript generated from input data. Treat untrusted strings and generated HTML according to the security policy of the page or notebook that will render them.
