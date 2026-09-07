#!/usr/bin/env raku
use v6.d;

sub arxiv-id(Str:D $input --> Str:D) {
    my $identifier = $input.trim.split('?')[0].split('#')[0];
    for <https://arxiv.org/ http://arxiv.org/ https://export.arxiv.org/ http://export.arxiv.org/> -> $prefix {
        $identifier = $identifier.substr($prefix.chars) if $identifier.starts-with($prefix);
    }
    for <abs/ pdf/ e-print/> -> $prefix {
        $identifier = $identifier.substr($prefix.chars) if $identifier.starts-with($prefix);
    }
    $identifier = $identifier.subst(/ '.pdf' $/, '');

    my $modern-id = /^ \d**4..5 '.' \d**4..5 [ 'v' \d+ ]? $/;
    my $legacy-id = /^ <[a..z A..Z . -]>+ '/' \d**7 [ 'v' \d+ ]? $/;
    die "Not an arXiv identifier or arXiv paper URL: $input"
        unless $identifier ~~ $modern-id || $identifier ~~ $legacy-id;
    $identifier
}

sub MAIN(
    Str:D $paper,
    Str :$directory = '.',
    Str :$output,
    Bool:D :$force = False,
) {
    my $identifier = arxiv-id($paper);
    my $target-directory = $directory.IO;
    die "Output directory does not exist: $target-directory" unless $target-directory.d;

    my $filename = $identifier.subst('/', '-', :g) ~ '.pdf';
    my $destination = $output.defined ?? $output.IO !! $target-directory.add($filename);
    die "Refusing to overwrite existing file: $destination (pass --force to replace it)"
        if $destination.e && !$force;

    my $url = "https://arxiv.org/pdf/$identifier";
    note "Downloading $url to $destination";
    my $process = run 'curl', '--fail', '--location', '--silent', '--show-error',
        '--output', $destination.Str, $url;
    exit $process.exitcode unless $process.exitcode == 0;
    say $destination;
}
