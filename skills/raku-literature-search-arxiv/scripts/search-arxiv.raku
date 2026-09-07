#!/usr/bin/env raku
use v6.d;

use HTTP::Simple;

my constant API-URL = 'https://export.arxiv.org/api/query';

sub xml-text(Str:D $text --> Str:D) {
    my $decoded = $text;
    $decoded = $decoded.subst('&quot;', '"', :g);
    $decoded = $decoded.subst('&apos;', "'", :g);
    $decoded = $decoded.subst('&lt;', '<', :g);
    $decoded = $decoded.subst('&gt;', '>', :g);
    $decoded = $decoded.subst('&amp;', '&', :g);
    $decoded.subst(/\s+/, ' ', :g).trim
}

sub first-element(Str:D $xml, Str:D $name --> Str:D) {
    my $match = $xml.match(/ '<' $name [\s+ <-[>]>]* '>' (.*?) '</' $name '>' /);
    $match ?? xml-text(~$match[0]) !! ''
}

sub attribute(Str:D $tag, Str:D $name --> Str:D) {
    my $match = $tag.match(/ $name '=' '"' (<-["]>*) '"' /);
    $match ?? xml-text(~$match[0]) !! ''
}

sub MAIN(
    Str:D :$query!,
    Int:D :$start = 0,
    Int:D :$max-results = 10,
    Str:D :$sort-by = 'relevance',
    Str:D :$sort-order = 'descending',
    Int:D :$timeout = 30,
    Bool:D :$raw = False,
) {
    die '--start must be zero or greater' if $start < 0;
    die '--max-results must be between 1 and 2,000' unless 1 <= $max-results <= 2_000;
    die '--sort-by must be relevance, lastUpdatedDate, or submittedDate'
        unless $sort-by eq any(<relevance lastUpdatedDate submittedDate>);
    die '--sort-order must be ascending or descending'
        unless $sort-order eq any(<ascending descending>);
    die '--timeout must be positive' if $timeout <= 0;

    my %parameters =
        search_query => $query,
        start        => $start,
        max_results  => $max-results,
        sortBy       => $sort-by,
        sortOrder    => $sort-order;

    my $response = http-get(API-URL, :query(%parameters), :$timeout);
    unless $response.ok {
        die "arXiv returned {$response.status} {$response.reason}: {$response.text}";
    }

    my $feed = $response.text;
    if $raw {
        print $feed;
        exit;
    }

    say "id\tpublished\ttitle\tauthors\tpdf";
    for $feed.match(/ '<entry' [\s+ <-[>]>]* '>' (.*?) '</entry>' /, :g) -> $entry-match {
        my $entry = ~$entry-match[0];
        my $id-url = first-element($entry, 'id');
        my $id = $id-url.split('/abs/')[*-1];
        my $title = first-element($entry, 'title');
        my $published = first-element($entry, 'published');
        my @authors = $entry.match(/ '<author' [\s+ <-[>]>]* '>' (.*?) '</author>' /, :g)
            .map({ first-element(~$_[0], 'name') });
        my $pdf = '';
        for $entry.match(/ '<link' (.*?) '/>' /, :g) -> $link-match {
            my $link = ~$link-match[0];
            if attribute($link, 'title') eq 'pdf' {
                $pdf = attribute($link, 'href');
                last;
            }
        }
        say ($id, $published, $title, @authors.join(', '), $pdf).join("\t");
    }
}
