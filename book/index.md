<span id="book-title">OCaml From the Ground Up</span>

<div id="dedication">To Betty Bourbaki.</div>

This is a work in progress introductory book on the [OCaml](https://ocaml.org) programming language.

## Contributing

The git repo is at [github.com/dmbaturin/ocaml-book](https://github.com/dmbaturin/ocaml-book).

What sets this book apart is that it's under [CC-BY-SA](https://creativecommons.org/licenses/by-sa/4.0/),
a free, strong copyleft license similar to the GNU GPL in spirit.

It belongs to the community and everyone can freely distribute and modify it. Even if the original authors no longer
have time to maintain it, the community can keep it up to date and distribute updated versions.

Right now the book is obviously incomplete, but together we can complete it faster than I can do it alone.
Every contribution counts! Beta reading and editing are important. If you want to write a whole chapter,
that's even better.

Just like with free software, the copyright stays shared between all contributors.

## Principles behind the book

1. Build it bottom up, never introduce a concept before it can be fully explained.
2. Stick with the standard library.
3. When third-party libraries are used, mention it prominently and use fully qualified names.
4. Don't make it REPL-centric.
5. Do not mention foxes or chunky bacon.

## Chapters to be written

If you want to help writing any of those, you are welcome!

<dl>
  <dt>Strings and buffers</dt>
  <dd>Immutable strings vs mutables <code>bytes</code>. Operations on strings. Operations on buffers.</dd>
  <dt>Polymorphic variants</dt>
  <dd>Polymorphic variants as a fallback to dynamic typing. Subtyping. Open types.</dd>
  <dt>Introduction to modules</dt>
  <dd>Defining modules. <code>open</code>, <code>let open ... in</code>, and <code>module M = ...</code>.</dd>
  <dt>Module signatures</dt>
  <dd>Module types. Signature ascription. Abstract types and information hiding.</dd>
  <dt>Functors</dt>
  <dt>Input and output</dt>
  <dd>File descriptor types. Input/output operations.</dd>
</dl>
