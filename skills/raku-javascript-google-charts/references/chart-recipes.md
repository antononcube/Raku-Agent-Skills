# Chart recipes

All examples assume:

```raku
use JavaScript::Google::Charts;
```

Use `format => 'html'` and `spurt` to create files, or omit `format` in a Jupyter JavaScript-display cell.

## Multi-series line or scatter chart

Convert each positional row to a hash when you need stable labels and an explicit column order.

```raku
my @names = <x Sine Cosine>;
my @data = (0, 0, 1), (1, 0.84, 0.54), (2, 0.91, -0.42);
my @records = @data.map({ @names.Array Z=> $_.Array }).map(*.Hash);

spurt 'waves.html', js-google-charts('LineChart', @records,
    column-names => @names,
    format => 'html',
    title => 'Waves',
    hAxis => { title => 'x' },
    vAxis => { title => 'amplitude' });
```

## Bubble and Sankey

Bubble needs label, x, y, group/color, and size fields. Sankey needs source, destination, and weight fields. Column order is meaningful.

```raku
my @bubbles = (
    { label => 'A', x => 10, y => 20, group => 'red', size => 12 },
    { label => 'B', x => 25, y => 12, group => 'blue', size => 20 },
);
spurt 'bubbles.html', js-google-charts('Bubble', @bubbles,
    column-names => <label x y group size>, format => 'html', :png-button);

my @flows = (
    { From => 'Input', To => 'Process', Weight => 100 },
    { From => 'Process', To => 'Output', Weight => 75 },
);
spurt 'flow.html', js-google-charts('SankeyDiagram', @flows,
    column-names => <From To Weight>, format => 'html');
```

## Timeline and annotations

`Date`/`DateTime` values are emitted as JavaScript dates. Use the special `role:annotation` field to insert annotations into supported classic charts.

```raku
my @schedule = (
    { person => 'Ada', task => 'Design', start => Date.new('2026-01-01'), end => Date.new('2026-01-15') },
    { person => 'Lin', task => 'Build',  start => Date.new('2026-01-16'), end => Date.new('2026-02-10') },
);
spurt 'schedule.html', js-google-charts('Timeline', @schedule,
    column-names => <person task start end>, format => 'html');
```

For a stacked column chart, add `:isStacked`; nested options are passed directly:

```raku
js-google-charts('Column', @records,
    column-names => <year actual forecast role:annotation>,
    :isStacked,
    bar => { groupWidth => '75%' },
    format => 'html');
```
