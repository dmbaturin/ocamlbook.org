# Higher order functions and parametric polymorphism

## Parametric polymorphism

So far we have only worked with functions that take values of types known beforehand.
However, we have already seen functions whose types were left without explanation, such as
`let hello _ = print_endline "hello world"` that we used to demonstrate the wildcard pattern.

What is its type? If you enter it into the REPL, you will see that it's `'a -> unit`.
What does the mysterious `'a` mean? Simply put, it's a placeholder for any type.
Essentially, a variable for types—a _type variable_.

It is easy to see that this function indeed works with arguments of any type and
behaves the same:

```ocaml
let hello _ = print_endline "hello world"

let () = hello ()
let () = hello 1
let () = hello false
```

This program will compile just fine and print `hello world` three times.

The wildcard pattern just discards the value. Will the behaviour or type of this function
change if we write it `let hello x = print_endline "hello world"` instead? If you experiment
with it, you will see that it doesn't. It seems logical: since the argument is still not used
in the function body in any way, its type shouldn't matter, and in the OCaml's type system,
it indeed doesn't.

This is known as _parametric polymorphism_.

There are two kinds of polymorphism in programming languages. The first kind, which is more
popular, is called ad hoc polymorphism, and is also known as function/method/operator overloading.
Ad hoc polymorphism allows you to use two or more functions with the same name but different type and behaviour
in the same program, for example, make `+` behave like addition for numbers and like concatenation
for strings<span class="footnote">That is, `2 + 3 - 5`, `"foo" + "bar" = "foobar"`</span>.
Many languages such as C++, Java, Scala, or Haskell implement it.

Parametric polymorphism allows you to use the same function for values of any type. It is relatively
more rare, but is gaining acceptance, for example in Scala and Swift, even though it's often not
mentioned by name.

Some languages, such as Ada, Java, or C++ clearly recognize the issue and provide a mechanism of
_generics_ or _templates_ that can be instantiated for different types. If you are familiar with them
you can think of polymorphic functions as generics that need not be instantiated.

OCaml doesn't support ad hoc polymorphism, so the word _polymorphism_ in this books always
refers to parametric polymorphism, unless specified otherwise.

Just like generics in Ada or Java, polymorphic types are often used to implement collections
that work with items of any type, but prevent attempts to use items of different types in the same
collection and thus preserve type safety. We will learn about polymorphic collections a bit later,
after learning about their building blocks—algebraic data types.

### A note on notation

A lot of time on the blackboard and in publications, people use small greek letters for type variables, such as
&alpha;, &beta; etc. where actual source code uses `'a`, `'b` and so on.

You can also see types of polymorphic written with a universal quantifier: _&forall; &alpha; . &alpha; &rarr; &alpha;_.
It emphasizes that the fact that a type variable can be replaced with any type. That is, for any type &alpha; such as `int` or `string`,
a function `f` can be specialized to it and become `int -> int`, or `string -> string`, or something else.

## Higher order functions and combinators

The function we used for demonstration is the simplest example of parametric polymorphism,
but it's quite useless since it doesn't do anything with its argument, so let's move on to
its more interesting application—implementing type safe higher order functions.

You may already be familiar with higher order functions from other languages, for example
Python or Ruby. They both provide a `map` function that takes a function
and some kind of an ordered collection and applies the function to its every element. Since they are
dynamically typed, if the type of that function is wrong, it will cause runtime errors.
In a dynamically typed language all is required to support higher order functions is support
for first class functions (i.e. functions as values).

OCaml is statically typed, so higher order functions need to be polymorphic if you want
to apply them to arguments of different types.

Since we are not ready for polymorphic collections yet, we'll consider simpler but useful examples
that require nothing but functions— _combinators_.

A combinator, strictly speaking, is an expression that has no free variables. That term is often loosely applied to functions
that help you make new functions from existing ones.

Let's examine two combinators from the standard library that can make your life easier: `@@` and `|>`.

The `@@` operator (and remember, operators are functions) takes a function and some other value and applies the function to that value.
You can use it to reduce the number of parentheses you need in your expressions. Compare these equivalent expressions:

```ocaml
let () = print_endline (string_of_int 5)

let () = print_endline @@ string_of_int 5
```

If it was not in the standard library, it could be trivially defined as:

```ocaml
let (@@) f x = f x
```

Its type is `('a -> 'b) -> 'a -> 'b`. It means that it takes a function of type `'a -> 'b` (that is, from any type
to any other type) and applies it to a value of type `'a`. It guarantees that if the type of the value does not
match the return type of the function, the program will fail to type check. While the type variable `'a` by itself
can stand for any type, if it appears on both sides of the arrow, the type it stands for must be the same on both
sides too.

Here is an example of an incorrect program:

```ocaml
let () = print_endline @@ 5
```

Another useful combinator is the reverse application combinator written `|>`. It is conceptually similar to the
application combinator `@@`, but has a different order of arguments: a value on the left and a function on the right. It can be defined as:

```ocaml
let (|>) x f = f x
```

Its type is `'a -> ('a -> 'b) -> 'b`. This is useful if you want to take a value and send it down a computation pipeline, for example:

```ocaml
let () = 5 |> string_of_int |> print_endline
```

The pipeline can be of any length, and can help you avoid a lot of extra parentheses in nested expressions,
and make them much easier to edit.

Now let's make our own combinator that the standard library doesn't provide: function composition.
It will take two functions and a value and apply them both to it:

```ocaml
let (+*) f g x = g (f x)
``` 

Its type is `('a -> 'b) -> ('b -> 'c) -> 'a -> 'c`. Since the value is its last argument, we can produce a new
function using it without mentioning any arguments at all, thanks to partial application:

```ocaml
let (+*) f g x = f (g x)

let print_int = print_endline +* string_of_int

let () = print_int 5
```

The type of the `+*` function we created is `('a -> 'b) -> ('c -> 'a) -> 'c -> 'b`. The types of both
functions it takes are enclosed in parentheses because arrows associate to the right, and we have to
group them explicitly to avoid confusion with a function of five arguments.

Combining functions without explicitly mentioning arguments, like we did in `let print_int = print_endline +* string_of_int`
is referred to as _point-free style_. The word &ldquo;point&rdquo; here refers not to the dot character, but
to the function argument, by analogy with mathematical functions that take point on a line or a plane.
Using it excessively can make programs hard to follow, so use your judgement.
