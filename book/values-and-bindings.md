# Values, expressions, and bindings

## The structure of OCaml programs

An OCaml program, loosely speaking, is a sequence of _expressions_ evaluated from top to bottom. There is no designated main function.
There are also no statements in OCaml, everything is an expression, all expressions have _values_, and all values have _types_.

There are many different kinds of expressions. The simplest kind of expression is a _constant_. There is no evaluation needed
to find out the value of a constant, so constant expressions always evaluate to themselves.

A constant is an example of a _pure_ expression. An expression is pure if its evaluation doesn't produce _side effects_, that is,
does not change the state of the program or anything outside the program. An expression that, for example, prints something on screen or
creates files when you evaluate it is called be _impure_. A pure expression always evalues to the same value, regardless of the program state.

This is an absolutely useless but valid OCaml program:

```
1
```

You can save it to a file, for example `one.ml` and compile it with `ocamlopt -o one ./one.ml`. The executable it produces will exit immediately.

What happens there? It's a program with a single expression, `1`, which is a constant of type `int`. Constants evaluate to themselves and are pure, so this
program evaluates `1` to `1`, which produces no side effects, and exits, since it has nothing else to do.

## Constants and types

 integer literal `1` is a constant of type `int`. Let's look at some other kinds of constants we can use:

<table>
  <th>
    <td>Type</td>
    <td>Examples</td>
  </th>
  <tr>
    <td>`bool`</td>
    <td>`true`, `false`</td>
  </tr>
  <tr>
    <td>int</td>
    <td>`1`, `10`, `0xCAFE` (hexadecimal), `0o3` (octal), `0b101` (binary)</td>
  </tr>
  <tr>
    <td>`float`</td>
    <td>`1.`, `3.5`, `0xFF.9B`</td>
  </tr>
  <tr>
    <td>`char`</td>
    <td>`'c'`, `'\n'`</td>
  </tr>
  <tr>
    <td>`string`</td>
    <td>`"hello world\n"`, `"foobar"`</td>
  </tr>
</table>

This list is not complete, but it's enough for the start.

Some things you should memorize right away:

* There is no automatic conversion between `int` and `float`
* Strings are *not* lists of `char`

## Function application and Hello World

Now let's write a slightly less useless program, the traditional &ldquo;hello world&rdquo;. 
For this we'll need to use a function. The standard library function that prints a string with a newline
at the end is `print_endline`, there's also `print_string` function that doesn't add a line break.

The syntax for function application is very simple: function name followed by its arguments. You need no
parentheses or any other special syntax.

This is a hello world program:

```ocaml
print_endline "hello world"
```

Now compile it and try it out:

```
$ ocamlopt -o hello ./hello.ml 

$ ./hello
hello world

```

For the sake of experiment, you can try applying the `print_endline` function to a non-string constant
and get your first type error:

```
$ cat hello.ml 
print_endline 1

$ ocamlopt -o hello ./hello.ml 
File "./test.ml", line 1, characters 14-15:
Error: This expression has type int but an expression was expected of type string

```

This is type inference in action: the compiler inferred the type of `1` as `int`, checked the type of the `print_endline`
function, and found that it expects a string. How it knows that `int` is a wrong type to use with `print_endline` though?
By checking it against the type of that function.

## The type of functions and the unit type

In OCaml, like in any functional language, functions themselves are values. If functions are values, they must also have types.
By typing `print_endline;;` in the REPL you can see that its type is `string -> unit`.

The arrow type `string -> unit` means that it's a function from type `string` to another type named `unit`.
When the compiler encountered the `print_endline 1` expression, it knew that the type of `1` is `int` rather than `string`,
and from the type of `print_endline` it knew that its argument must be of type `string`, so it was able to detect the type error.

Now let's examine the &ldquo;return type&rdquo; of that function on the right hand side of the arrow.
We are already familiar with `string`, but the `unit` is new. What is it and why is it needed?

As you remember, all expressions have types,
so when `print_endline "hello world"` is evaluated, the result of evaluation must have some type. A function in OCaml
cannot &ldquo;return nothing&rdquo;.

Since many functions are used just for their side effects and don't produce any useful values, some type must have
been invented just to have them comply with the &ldquo;all values have types&rdquo; rule.

The `unit` type is a type that has only one value, and it was invented specially for this purpose. Its only possible value
is a special constant written `()`.
Whether it was made to look this way to mimic calling functions without arguments in other languages
is debatable, you should just remember that the constant `()` has type `unit`.

The unit type is also used for functions that take no useful arguments, but have to take something
because in OCaml a function cannot have no arguments either. The &ldquo;arrow type&rdquo; must always have both
a left and a right hand side.

An example of a function with `unit -> unit` type is `print_newline` that just prints a line break.
A program that prints a line break thus can be written like this:

```ocaml
print_newline ()
```

## Bindings and scopes

So far we have only written programs that consist of a single expression. Let's see how to introduce variables
and how to use multiple expressions—in OCaml these concepts are related.

In Java or C++, a &ldquo;variable&rdquo; is a container for values: you can _declare_ a variable without associating
it with any value, and then _assign_ a value to it.

In OCaml, a name cannot exist without a value. Variables are called _bindings_—names _bound_ to values.
The same name can later be bound to a different value, but the value itself will not change.

Bindings are created with the `let` keyword. There are two ways to use `let`-bindings: one allows you to make a binding accessible
only to one expression that follows it (`let <name> = <value> in <expr>`), while the other (`let <name> = <value>`) makes a binding
accessible to all expressions below it. This is not a standard OCaml terminology, but for convenience let's call them _local_
and _global_ bindings respectively.

Let's rewrite the Hello World program with a local binding:

```
$ cat ./test.ml 
let hello = "hello world" in print_endline hello

$ ocamlopt -o test ./test.ml 

$ ./test 
hello world
```

We could also use two bindings instead of one to demonstrate that `let ... in` constructs can be nested:

```ocaml
let hello = "hello " in
let world = "world" in
print_endline (hello ^ world)
```

The `^` operator means string concatenation. What happens here? Earlier it was said that in the `let ... in` form,
the binding will only be available to the expression that follows the `in` keyword, but remember that `let`-bindings
are themselves expressions, and they can be chained.

Every `let`-binding opens a new _scope_.
Here we first create a scope where the name `hello` is bound to a string constant `"hello "`, then inside it
we create a scope where the name `world` is bound to a string constant `"world"`, and in that scope,
evaluate the `print_endline (hello ^ world)` expression.

Now let's try global bindings. Before we can try them, we need to learn how to use multiple expressions
in our programs. You might have already noticed that we have not used a semicolon or another statement terminator.
Simply writing:

```
print_endline hello
print_endline world
```

will not work because it will be parsed by the compiler as an attempt to apply the `print_endline` function to three arguments, of which
the first is a string, the second if a function, and the third is string again; and this will fail because
the type of `print_endline` is `string -> unit`. In the example above we avoided the issue by applying
`print_endline` to another expression in parentheses, but this isn't always feasible.

How do we write a program with multiple independent expressions parse correctly then?
It's time to learn a secret of `let`: its left hand side is not just a name, but a _pattern_.

Patterns have multiple uses and forms, which we will explore later. For now, you need to know that a name
is a pattern. Another possible pattern is the _wildcard pattern_ written `_`, which comes in handy when
you need to have an expression evaluated, but don't want to bind its value to any name.

To create independent top level expressions you can use &ldquo;fake&rdquo; bindings with wildcard patterns:

```ocaml
let hello = "hello "
let world = "world"

let _ = print_string hello
let _ = print_endline world
```

A constant is also a valid pattern. As you remember, the type of `print_endline` is `string -> unit`, so it always
evaluates to the `()` constant. Thus you can also write:

```
let () = print_string hello
let () = print_endline world
```

In this case you need to watch that the constant pattern on the left hand side and the expression on the right hand side
have the same type. When you start using more complex expressions, this can serve as a useful safeguard against
accidentally using an expression of a non-unit type on the right hand side.

The wildcard pattern accepts values of any types in the `let`-binding context, but a constant pattern, such as `()`, will force type checking.
If you know that your expression must have type `unit`, it's always better to write `let () =` rather than `let _ =`
to have possible type errors caught.

Here is an example of an error that is made invisible by the wildcard pattern:

```ocaml
let _ = print_endline
```

The program incorrect, but syntactically valid because functions are values, and the right hand side of a `let`-binding can be any value,
including a function.
In this example it's obvious that the argument is missing, but if `print_endline` function had more arguments, it would be
easier to forget one. Since the wildcard pattern completely ignores the value, the program will compile, but print nothing.

However, if you use the unit pattern, the program will fail to compile because `print_endline` function is not a value of type unit:

```ocaml
let () = print_endline
```

If you have multiple expressions of the `unit` type, you can chain them using semicolons. In OCaml, the semicolon
is an _expression separator_ rather than a statement terminator, so you will need at least one unit or wildcard binding to use it:

```ocaml
let greeting = "hello world"

let () = print_string greeting; print_newline ()
```

If you try this with expressions of types other than `unit`, the compiler will produce a warning. To suppress the warning,
you can apply the `ignore` function to your expression, as in:

```ocaml
let () = ignore 1; print_endline "hello world"
```

Finally, you can also use `;;` like in the REPL, but it's a very bad style and should be avoided whenever possible.

### Shadowing

As you remember, every new binding opens a new scope. We can illustrate it like this:

```ocaml
(* Scope 0 *)

let hello = "hello " (* Opens scope 1 *)

(* Scope 1 *)

let world = "world" (* Opens scope 2 *)

(* Scope 2, (hello = "hello ", world = "world") *)

let () = print_endline (hello ^ world)

```

Now let's stop and think what happens if we make two bindings with the same name.

```ocaml
(* Scope 0 *)
let hello = "hello"

(* Scope 1 *)
let hello = "hi"

(* Scope 2 *)
let () = print_endline hello

```

If you compile this program and run it, you'll see that it prints `hi`. This is because the second binding
redefined the value of `hello` in the scope 2. This is called _shadowing_. It is distinct from variable
assignment. The original value of `hello` did not change, it just became inaccessible from the new scope
where it was redefined. Is the original value of `hello` lost forever? In the example above, yes, it will be
completely inaccessible. In general case, the question is more interesting, but we will lean about it later
when we get to functions and closures.

The case when difference from variable assignment is especially visible is `let ... in` bindings.
It is perfectly safe to redefine a binding locally and it will have no effect on the rest of the program.

Consider this program:

```ocaml
(* Scope 0 *)
let hello = "hello "

let hello = hello ^ "world" in
(* Local scope 1 *)
print_endline hello

(* Back to scope 0 *)
let () = print_endline hello
```

It will print `hello world`, and then print `hello`, because our `let ... in` binding only redefines the `hello`
variable for the `print_endline hello` expression.
