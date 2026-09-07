#!/usr/bin/env raku
use v6.d;

use HTTP::Tiny;

my constant API-URL = 'http://export.arxiv.org/api/query';

sub query-component(Str:D $value --> Str:D) {
    $value.encode.list.map(-> $byte {
        my $unreserved = ($byte >= 0x41 && $byte <= 0x5A)
            || ($byte >= 0x61 && $byte <= 0x7A)
            || ($byte >= 0x30 && $byte <= 0x39)
            || $byte == 0x2D || $byte == 0x2E || $byte == 0x5F || $byte == 0x7E;
        $unreserved ?? $byte.chr !! $byte.fmt('%%%02X')
    }).join
}

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
    Bool:D :$raw = False,
) {
    die '--start must be zero or greater' if $start < 0;
    die '--max-results must be between 1 and 2,000' unless 1 <= $max-results <= 2_000;
    die '--sort-by must be relevance, lastUpdatedDate, or submittedDate'
        unless $sort-by eq any(<relevance lastUpdatedDate submittedDate>);
    die '--sort-order must be ascending or descending'
        unless $sort-order eq any(<ascending descending>);
    my @parameters =
        search_query => $query,
        start        => $start,
        max_results  => $max-results,
        sortBy       => $sort-by,
        sortOrder    => $sort-order;

    my $url = API-URL ~ '?' ~ @parameters.map(-> $parameter {
        query-component($parameter.key.Str) ~ '=' ~ query-component($parameter.value.Str)
    }).join('&');
    my %response = HTTP::Tiny.new.get($url);
    unless %response<success> {
        my $body = (%response<content> // Blob.new).decode;
        die "arXiv returned {%response<status> // 'an unknown status'} "
            ~ "{%response<reason> // ''}: $body";
    }

    my $feed = (%response<content> // Blob.new).decode;
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
        my @authors = $entry.match(/ '<author' [\s+ <-[>]>]* '>' (.*?) '</author>' /, :g).map({ first-element(~$_[0], 'name') });
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
