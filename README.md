# ocaml-book
A free culture OCaml textbook

## Contributing

This book is licensed under Creative Commons Attribution Share-Alike,
a free culture license.

It's meant to be a collaborative effort that belongs to the community
and can freely shared, updated and maintained even if the original authors no longer
have the time and motivation to maintain it.

Everyone is welcome to contribute. Just create a pull request.

## Building

You will need:

* [soupault](https://soupault.neocities.org) website generator, version 1.8 or newer.
* [cmark](https://github.com/commonmark/cmark) for Markdown to HTML conversion
* [highlight](http://www.andre-simon.de/doku/highlight/en/highlight.php) for static syntax highlighting
* The OCaml compiler for build-time example typechecking
* GNU Make

Once you have all dependencies, run `make all`, the output will be in `build/`.

## Reading

A draft more or less in sync with the repo lives at https://ocaml-book.baturin.org
I should setup a CI for it eventually.
