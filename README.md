# ocaml-book

A free (as in freedom) OCaml textbook.

## Contributing

This book is licensed under Creative Commons Attribution Share-Alike,
a free culture license.

It's meant to be a collaborative effort that belongs to the community
and can freely shared, updated and maintained even if the original authors no longer
have the time and motivation to maintain it.

Everyone is welcome to contribute. Just create a pull request.

## Building

You will need:

* [soupault](https://soupault.neocities.org) website generator, version 2.0.0 or newer.
* [cmark](https://github.com/commonmark/cmark) for Markdown to HTML conversion.
* [highlight](http://www.andre-simon.de/doku/highlight/en/highlight.php) for static syntax highlighting
* The OCaml compiler for build-time example typechecking
* GNU Make

Once you have all dependencies, run `make all`, the output will be in `build/`.

### Note on cmark

cmark 0.29 made "safe mode" the default and removes HTML tags from Markdown source
(why a locally run program working with local files would want to do that by default is beyond me).
Why they didn't add a backwards-compatibility mechanism like an environment variable is also beyond me.

Anyway, the `md = "cmark --unsafe"` line in `soupault.conf` will only work with cmark >=0.29

If you are building on a system with an older cmark version, remove `--unsafe`.

## Reading

A live version is available at https://ocamlbook.org
