---
name: raku-literature-search-arxiv
description: Search arXiv for scientific papers and download arXiv PDFs using the included Raku command-line helpers.
---

# arXiv literature search

Use this skill when a task calls for finding or downloading papers hosted on
arXiv. The helpers are deliberately small command-line tools: search returns
the metadata needed to select a paper, and download fetches its PDF.

## Search

The search helper requires `HTTP::Simple` (for example, install it with `zef
install HTTP::Simple` when it is not already available).

Run `scripts/search-arxiv.raku` with an arXiv API search expression:

```sh
raku scripts/search-arxiv.raku --query 'cat:cs.AI AND ti:"large language models"' --max-results=20
```

It uses `HTTP::Simple` and arXiv's Atom API. Results are tab-separated with the
identifier, publication date, title, authors, and PDF URL. Use `--raw` only
when the Atom feed itself is required. Read
[references/query-syntax.md](references/query-syntax.md) before constructing
fielded, boolean, or date-range queries.

## Download

After selecting an identifier, download its PDF with:

```sh
raku scripts/download-paper.raku 2501.01234 --directory papers
```

The download helper accepts an arXiv identifier or an `abs`, `pdf`, or
`e-print` arXiv URL. It will not overwrite an existing output unless `--force`
is supplied. Downloading creates a local file, so use the destination the user
requested and confirm before any broader or external publication workflow.
