---
name: raku-javascript-google-charts
description: Create Google Charts plots and charts from Raku with JavaScript::Google::Charts, including Jupyter output, standalone HTML, and the js-google-charts CLI.
---

# JavaScript::Google::Charts

Use this skill for Raku visualizations that should be rendered by Google Charts. The package generates browser JavaScript; it does not create a static image itself. Prefer it for the chart types implemented by the package, and consult the [Google Charts documentation](https://developers.google.com/chart/interactive/docs/gallery) for chart-specific option names and semantics.

## Start with the data shape

`js-google-charts` ultimately receives an iterable of associative records. For simple inputs, the package converts numeric lists and rows automatically:

- A numeric list works for `Scatter`, `Line`, `Bar`, `Pie`, `Histogram`, and `Bubble`.
- A list of positional rows works for `Scatter`, `Line`, and `Combo`; it is turned into numbered columns. Use `column-names => <x series-a series-b>` when names matter.
- For general charts, build records explicitly and pass `column-names` in the desired order. This is especially important for Bubble, Sankey, Timeline, Geo, and Table charts.
- Values may be strings, booleans, numbers, `Date`, or `DateTime`. A key named `role:annotation` becomes a Google Charts annotation column.

Pass ordinary Google Chart options as named Raku arguments; nested Raku hashes become JSON options. The package supplies `width => 600` and `height => 400` by default. Use `:png-button` only with `format => 'html'` to add a downloadable PNG link.

## Select an output mode

### Jupyter (Raku kernel)

Load the package, then use the Raku kernel's JavaScript display magic (`%% js`, also documented as `%% javascript`) for both the one-time loader configuration and each chart cell. Keep `format` at its default, `jupyter`.

```raku
use JavaScript::Google::Charts;

# Run this once in a %% js / %% javascript cell.
js-google-charts-config()
```

```raku
%% js
use JavaScript::Google::Charts;

my @points = (1, 4, 2, 7, 5);
js-google-charts('Scatter', @points,
    title => 'Measurements',
    hAxis => { title => 'Sample' },
    vAxis => { title => 'Value' });
```

The generated code relies on the Jupyter `element` supplied by the magic. Do not set `format => 'html'` for this mode unless the notebook environment is explicitly rendering HTML output (for example, its `#% html` facility).

### Standalone HTML

Request `format => 'html'`, then write the returned complete document. Give each embedded chart a distinct `div-id`.

```raku
use JavaScript::Google::Charts;

my @sales = (
    { month => 'Jan', revenue => 120 },
    { month => 'Feb', revenue => 155 },
    { month => 'Mar', revenue => 135 },
);

spurt 'sales.html', js-google-charts('Column', @sales,
    column-names => <month revenue>,
    format => 'html',
    div-id => 'monthly-sales',
    title => 'Monthly revenue',
    width => 800, height => 500);
```

Open the resulting file in a browser with network access: its Google Charts loader is fetched from `https://www.gstatic.com/charts/loader.js`.

### Command line

Run the supplied script from a checkout with `-Ilib`, or use the installed `js-google-charts` executable. It emits the requested document to standard output. `--args` is required and must be a JSON object, even when empty.

```sh
js-google-charts Scatter '1 4 2 7 5' --width=800 --height=500 --args='{}' > scatter.html

printf '1 4 2 7 5\n' | js-google-charts Histogram --args='{"title":"Distribution"}' > histogram.html
```

CLI input is numeric: comma-separated groups without spaces, such as `'1,4 2,7 3,5'`, form rows; otherwise numbers are split from text. Use Raku code for labeled records, dates, strings, or complex chart options.

## Chart names and caveats

Implemented aliases include `Bar`, `Column`, `Pie`, `Area`, `SteppedArea`, `Bubble`, `Gauge`, `GeoChart`, `Histogram`, `SankeyDiagram`, `Scatter`/`ListPlot`, `Line`, `Combo`, `Table`, `Timeline`, and `WordTree`. `Bar` is horizontal by default; add `:!horizontal` for vertical bars, or use `Column`.

`Line` uses Google Material Lines; use `LineChart` when the classic Google LineChart behavior is needed. The package loads the Google packages it needs automatically in standalone HTML. For option and record examples beyond basic plots, read [references/chart-recipes.md](references/chart-recipes.md).
