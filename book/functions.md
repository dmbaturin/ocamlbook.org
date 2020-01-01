# Functions

In previous chapters we've learnt how to use variables and arithmetic functions.
Now it's time to learn how to make our own functions.

## Anonymous functions

We will start with anonymous functions. The reason is that in OCaml, named functions are simply
anonymous functions bound to names, and the special syntax for creating named functions is merely
a syntactic sugar.

This is the syntax for anonymous functions: `fun <formal parameter> -> <expression>`.

Let's write a simple program using an anonymous function:

```
let a = (fun x -> x * x) 3

let () = print_int a
```

The `fun x -> x * x` function takes a single argument and squares it. Since we already know that
the `*` operator works with integers, we can infer that this function has type `int -> int`.
In the program it is applied to 3 and the result is bound to `a`, which is later printed.

## Named functions

Now, before we learn the syntactic sugar for named functions, let's create a named function
the hard way:

```
let square = fun x -> x * x

let a = square 3 (* 9 *)
```

As you can see, the syntax is exactly the same for variable and function bindings.
In OCaml, they are both expressions. Like constants, functions (if not applied to
any arguments), evaluate to themselves. 

## Bindings, scopes, and closures

Now let's examine how functions interact with other bindings. Unlike other expressions,
functions contain _free variables_. A free variable is a variable whose name is not bound to any value.

In our `square` example, `x` is a free variable, and the expression in the right-hand side
contains no other variables. When that function is applied to an argument, `x` will be replaced
with that argument in the `x * x` expression and that expression will be evaluated.
We can visualize that process like this:

```
square 3 =
(fun x -> x * x) 3 =
(fun 3 -> 3 * 3) =
3 * 3 =
9
```

Of course, if we have previously created any bindings, we can refer to them in our functions.

```
let two = 2

let plus_two = fun x -> x + two

let number = plus_two 10 (* number = 12 *)

let () = print_int number
```

However, what happens if the name `two` is redefined after the definition of `plus_two`? Let's try and see what happens:

```
let two = 2

let plus_two = fun x -> x + two

let two = 3

let () = print_int (plus_two 10)
```

This program will print 12 rather than 13 (i.e. 10 + 2, not 10 + 3).

The reason is that functions capture bound variables from the scope where they were created—forever. This is called _lexical scoping_.
If the name `two` was bound to 2 at the time we defined `plus_two`, then `plus_two` will be `fun x -> x + 2`,
even if we redefine the variable `two` later.

Some languages use a different approach called _dynamic scoping_ where variable names are resolved
when the function is evaluated, so redefining a variable retroactively changes the behaviour of all functions
that use it. Dynamic scoping makes reusing variable names a risky thing to do. Since OCaml is lexically scoped,
you can reuse variable names safely.

We can rewrite the `plus_two` function using a `let ... in` binding instead:

```
let plus_two =
  let two = 2 in
  fun x -> x + two

print_int (plus_two 3)
```

Here, the variable `two` doesn't even exist for the rest of the program because it was a local
binding only visible to the `fun x -> x + two` expression, but it continues to exist for the
`plus_two` function.

A function stored together with its environment is called a _closure_. Since you cannot prevent
functions from capturing their environment in OCaml, there is no distinction between functions
and closures, and for simplicity they are all called just functions. You should always
remember about the effect though, and it has important practical uses.

For example, it can be used to create functions of multiple arguments using only functions
of one argument. In fact, this is how functions of multiple arguments work in OCaml.
Any function &ldquo;of two arguments&rdquo; really takes one argument and produces another
function where the first argument is fixed but the second one is free.

## Functions of multiple arguments and currying

Let's write a function for calculating the average of two values.

```
let average = fun x -> (fun y -> (x +. y) /. 2.0)
```

Its type is `float -> (float -> float)`. It means that when applied to one argument (like `average 2.0`),
this function creates another function, where `x` is bound, but `y` is free—a closure.
That new function can be applied to another argument to complete the computation.

The expression `let f = average 3.0` will be equivalent to `let f = fun y -> (3.0 +. y) /. 2.0)`,
because functions capture bound variables from the scope where they are created.
Then you can apply it to something else, like `(average 3.0) 4.0`.

We used parentheses in `float -> (float -> float)` and `(average 3.0) 4.0` for clarity, but in fact they are not needed.

OCaml and most other functional languages use a convention where arrows associate to the right.
The type of the `average` function can be written `float -> float -> float`, and it's assumed to mean `float -> (float -> float)`.
Likewise, you can apply that function without any parentheses: `let a = average 3.0 4.0`.

The process of creating a function &ldquo;of multiple arguments&rdquo; from functions of one argument
is called _currying_, after Haskell Curry who was already mentioned in the history section,
even though he wasn't the first to invent it, as it often happens with named laws.

## Partial application

A big advantage of curried functions is that they make partial application especially easy.
In many languages, partial application either needs a special syntax or isn't possible at all.
In languages that use closures and currying, it is very easy: just use only the first argument(s)
and omit the rest, and you get a function with first argument(s) fixed that can be applied to different
remaining arguments as needed.

To see some real examples, let's introduce the `Printf.printf` function that is used for
formatted output. The reason we used `print_int`, `print_string` and similar in the first chapter
is that we pretended that we know nothing about functions with more than one argument until we
had a chance to learn about them properly. In practice, people almost always use `Printf.printf`
instead because it's much more powerful and convenient. Its name means that it belongs to the `Printf`
module that comes with the standard library, but we will discuss modules later, for now let's consider
it just an unusual name.

The type of that function is rather complicated and we will not discuss it right now. Let's just say that
its first argument is a format string. Format string syntax is very similar to that of C and all languages
inspired by its `printf`. The Hello World program could be written:

```
let () = Printf.printf "%s\n" "hello world"

```

When applied to a format string, that function will produce functions of one or more arguments depending
on the format string. For example, in `let f = Printf.printf "%s %d"`, `f` will be a function of type `string -> int -> unit`.

Now let's write a simple program using `Printf.printf` and partial application of it:

```
let greet = Printf.printf "Hello %s!\n"

let () = greet "world"
```

The `"Hello %s!\n"` string is stored in a closure together with the function that `Printf.printf` produced from it.
A similar idiom in an object oriented language might have been `greeter = new Formatter("Hello %s!\n"); greeter.format("world")`.
As Peter Norvig put it in his [Design Patterns for Dynamic Languages](http://norvig.com/design-patterns/design-patterns.pdf) talk, objects
are data with attached behaviour, while closures are behaviours with attached state data.

One danger of curried functions, however, is that failing to supply enough arguments is not a syntax error,
but a valid expression, just not of the type that might be expected. Luckily, since OCaml is statically typed,
this kind of errors rarely goes unnoticed and programs fail to compile.

Consider this program:

```
let add = fun x -> (fun y -> x + y)

let x = add 3 (* forgot second argument *)

let () = Printf.printf "%d\n" x
```

It will fail to compile because `add 3` expression has type `int -> int`, while `Printf.printf "%d\n"` is `int -> unit`.

## The syntactic sugar for function definitions

Of course, creating functions by binding anonymous functions to names can quickly get cumbersome, especially when
multiple arguments are involved, so OCaml provides syntactic sugar for it.

Let's rewrite the functions we've already written in a simpler way:

```
let plus_two x = x + 2

let average x y = (x +. y) /. 2.0
```

OCaml also supports multiple arguments to the `fun` keyword too, so anonymous functions of multiple arguments can be
easily created: `let f = fun x y -> x + y`.

## Formal parameter is a pattern

We have already seen that the left hand side of a `let`-expression can be not only a name, but any valid _pattern_,
including the wildcard or any valid constant. This also applied to the left hand side of function definitions.

For example, we can create a function that ignores its argument using the wildcard pattern:

```
let always_zero _ = 0

let always_one = fun _ -> 1
```

We can also use the `()` constant, which is a constant of type `unit`, as a function argument. Since functions with
no arguments cannot exist in OCaml, this is the standard for functions used solely for their side effects:

```
let print_hello () = print_endline "hello world"

let () = print_hello ()
```

The `print_hello` function in this example has type `unit -> unit`.

## Operators are functions

It's not really true that we haven't seen functions of multiple arguments in the first chapter,
we just pretended that operators are not functions. While in many languages they are indeed special constructs,
in most functional languages operators are just functions that can be used in an infix form.

In OCaml, every infix operator can also be used in a prefix form if enclosed in parentheses:

```
let a = (+) 2 3
let b = (/.) 5 2
let c = (^) "hello " "world"
```

You can also define your own operators like any other functions using the same parentheses syntax:

```
let (^^) x y = x ^ x ^ y ^ y

let s = "foo" ^^ "bar" (* foofoobarbar *)

```

You can also define a prefix operator if you use a name that starts with a tilde:

```
let (~*) x = x * x

let a = ~* 2 (* 4 *)
```

The first character of the operator name determines its associativity and precedence
<span class="footnote">This system is rigid, but predictable, which is especially important
when you import operators from a module.</span>.

## Named and optional arguments

OCaml supports named and optional arguments. Named arguments are preceded with the tilde symbol:

```
let greet ~greeting ~name = Printf.printf "%s %s!\n" greeting name

let () = greet ~name:"world" ~greeting:"hello"
```

If you look at the inferred type of the `greet` function, you will see that argument labels
are embedded in its type: `greeting:string -> name:string -> unit`.
Named arguments can be used in any order as long as you specify the labels, but if arguments come
in the same order as they are defined in the function, you can omit the labels:

```
let greet ~greeting ~name = Printf.printf "%s %s!\n" greeting name

let () = greet "hello" "world"
```

The syntax of optional arguments is a bit more complicated. Suppose we want to write a function
that takes a string and prints `hello <string>` by default, but allows us to use a different greeting,
for example, &ldquo;hi&rdquo;
This is how we can do it:


```
let greet ?(greeting="hello") name = Printf.printf "%s %s!\n" greeting name

let () = greet "world" ~greeting:"hi"
```

The inferred type of this `greet` function will look like this: `?greeting:string -> string -> unit`.
It is recommended to put optional arguments first, because otherwise you will not be able to omit them.

## Exercises

Using the `Printf.printf` function, make a `join_strings` function that takes two strings and an optional
separator argument that defaults to space and joins them. What is the type of that function?

Write a function that has type `int -> float -> string` using any functions we already encountered.
