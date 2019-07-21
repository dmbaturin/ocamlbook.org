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

```
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
It is the ability to use two or more functions with the same name but different type and behaviour
in the same program, for example, make `+` behave like addition for numbers but concatenation
for strings. The majority of structured and object oriented languages implement it.

Parametric polymorphism is ability to use the same function for values of any type. It is relatively
more rare, but is gaining acceptance, for example in Scala and Swift, even though it's often not
mentioned by name.

Some languages, such as Ada, Java, or C++ clearly recognize the issue and provide a mechanism of
_generics_ or _templates_ that can be instantiated for different types. If you are familiar with them
you can think of polymorphic functions as generics that need not be instantiated.

Since OCaml doesn't support ad hoc polymorphism (it would require sacrificing the ability to
write statically typed programs without any type annotations), hereafter the word _polymorphism_
refers to parametric polymorphism.

Just like generics in Ada or Java, parametric polymorphism is often used to implement collections
that work with items of any type, but prevent attempts to use items of different types in the same
collection and thus preserve type safety. We will learn about polymorphic collections a bit later,
after we learn about their building blocks—algebraic data types.

### A note on notation

A lot of time on the blackboard and in publications, people use small greek letters for type variables, such as
&alpha;, &beta; etc. where actual source code uses `'a`, `'b` and so on.

You can also see types of polymorphic written with universal quantifier: _&forall; &alpha; . &alpha; &rarr; &alpha;_.
It is to emphasize that the type variable can be replaced with any type. That is, for any type &alpha; a function `f`
can be specialized to it and become `int -> int`, or `string -> string`, or something else.

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

A combinator, strictly speaking, is an expression that has no free variables. Loosely, that term is often used for any functions
that help you make new functions from existing ones.

Let's examine two combinators from the standard library that can make your life easier: `@@` and `|>`.

The `@@` operator (and remember, operators are functions) takes a function and some other value and applies the function to that value.
Its practical use is to reduce the number of parentheses you need in your expressions. Compare these equivalent expressions:

```
let () = print_endline (string_of_int 5)

let () = print_endline @@ string_of_int 5
```

If it was not in the standard library, it could be trivially defined as:

```
let (@@) f x = f x
```

Its type is `('a -> 'b) -> 'a -> 'b`. It means that it takes a function of type `'a -> 'b` (that is, from any type
to any other type) and applies it to a value of type `'a`. It guarantees that if the type of the value does not
match the return type of the function, the program will fail to type check. While the type variable `'a` by itself
can stand for any type, if it appears on both sides of the arrow, the type it stands for must be the same on both
sides too.

Here is an example of an incorrect program:

```
let () = print_endline @@ 5
```

Another useful combinator is the reverse application combinator written `|>`. It is conceptually similar to the
application combinator `@@`, but it differs in that it has a value on the left hand side and a function on the
right hand side. It can be defined as:

```
let (|>) x f = f x
```

Its type is `'a -> ('a -> 'b) -> 'b`. This is useful if you want to take a value and send it down a computation pipeline, for example:

```
let () = 5 |> string_of_int |> print_endline
```

The pipeline can be of any length, and can help you avoid a lot of extra parentheses in nested expressions,
and make them much easier to edit.

Now let's make our own combinator that the standard library doesn't provide: function composition.
It will take two functions and a value and apply them both to it:

```
let (+*) f g x = g (f x)
``` 

Its type is `('a -> 'b) -> ('b -> 'c) -> 'a -> 'c`. Since the value is its last argument, we can produce a new
function using it without mentioning any arguments at all, thanks to partial application:

```
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
