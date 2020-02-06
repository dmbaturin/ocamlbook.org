# Error handling

Every program that deals with user input and the operating system has to handle error conditions.
OCaml is a multi-paradigm language and there is more than one way to handle errors.

None of them is inherently superior to the other, and it's possible to mix them.

## The functional way: option and result types

It's common to indicate error conditions with option of result types. This is how they
are defined in the standard library:

```ocaml
type 'a option = None | Some of 'a

type ('a, 'b) result = Ok of 'a | Error of 'b
```

The `'a option` type allows you to signal that the function could not produce a result
with `None` or return a value with `Some value`.

The `('a, 'b) result` type allows
you to also indicate the error condition. Note that both data constructors of the result
type are polymorphic, so your error message doesn't have to be a string.

The option type is commonly used when there can be only one, obvious error condition.
For example, in functions that search for an element in an collection, it indicates
that nothing was found.

Let's demonstrate it with `List.find_opt : ('a -> bool) -> 'a list -> 'a option` function
from the standard library that takes a function of type `'a -> bool` and checks if it's true
for any element of a list until it finds one or the end of the list is reached:

```ocaml
let xs = [1; 3; 5; 7]

let () =
  let res = List.find_opt (fun x -> x mod 2 = 0 ) xs in
  match res with
  | Some value -> Printf.printf "Found even number %d\n" value
  | None -> Printf.printf "List has no even numbers"
```

If there can be different error conditions, it's better to use the result type:

```ocaml
(* (//) : int -> int -> (int, string) result *)
let (//) x y =
  if y = 0 then Error "Division by zero"
  else Ok (x / y)

let () =
  let res = 5 // 0 in
  match res with
  | Ok value -> Printf.printf "Result is %d\n" value
  | Error msg -> Printf.printf "Error: %s\n" msg
```

The advantage of this approach is that function types indicate possible errors conditions,
and those errors are impossible to ignore: you have to use pattern matching to unwrap the value
from `Some` or `Ok` before you can use it.

The disadvantage is that you _have to_ unwrap the value before you can use it, so errors
must be handled immediately.

### The `bind` combinator

Handling all option or result values by hand can be a tedious task. The standard library
provides so called `bind` functions for them to allow working with option
or result types more easily. With a `bind`, you can write a pipeline of functions
where `Some` or `Ok` values are passed down the pipeline, but error values stop it and propagate back up.

For a type `'a t`, a `bind` function has this type: `'a -> ('a -> 'a t) -> 'a t`.

Thus for the option we have a function `Option.bind : 'a option -> ('a -> 'a option) -> 'a option`.

From its type we can see that it takes a value of type `'a option` and a function of type `'a -> 'a option`.
Internally, it passes the value to that function. What's important is that the the input of the function
it takes is `'a`, not `'a option`—the bind function deals with the errors on its own so that your
function only needs to know how to produce one, but not how to handle it.

This is how it's implemented:

```ocaml
let bind o f =
  match o with
  | None -> None
  | Some v -> f v
```

As you can see, it simply returns `None` if the value is `None` or applies the function `f`
to the value attached to `Some`.

For ease of use, the bind function is usually aliased to an infix operator, traditionally `>>=`.
Let's rewrite our example using the `Option.bind`:

```invalid-ocaml
let (>>=) = Option.bind

let handle_search_result o =
  match o with
  | None -> Printf.printf "Nothing found\n"
  | Some v -> Printf.printf "Found %d\n" v

let is_even x = x mod 2 = 0

let () =
  List.find_opt is_even [1; 3; 5] >>= handle_search_result
```

If we had multiple functions of type `'a -> 'a option`, we could write a much longer pipeline,
and still have to deal with unwrapping the option type explicitly only at the last step:

```invalid-ocaml
let y = x >>= f >>= g >>= h in
match y with
| None -> ...
```

This approach amplifies the disadvantage of the option type: if something in the pipeline returns
`None`, we don't know what went wrong or even where in the pipeline it happened.

The `Result.bind` works in a similar way, but since you can attach information about the error,
you can make your pipeline much easier to debug and give the user a sensible error message.

A type `t` with functions `bind : 'a t -> ('a -> 'a t) -> 'a t` and `return : 'a -> 'a t`
defined for it is known as a _monad_<span class="footnote">For a good introduction, see Philip Wadler's paper
[Monads for functional programming](http://homepages.inf.ed.ac.uk/wadler/papers/marktoberdorf/baastad.pdf").</span>.
In our case we use `Some` and `Ok` data constructors
as &ldquo;virtual&rdquo; `return` functions. Error handling is the simplest use case for the monad pattern, it
can encapsulate different kinds of complexity: for example, the [Lwt](https://ocsigen.org/lwt/) library uses it for
asynchronous computations and multitasking.

## The imperative way: exceptions

Like many other languages, OCaml has exceptions and exception handling. Even if you prefer purely functional
style, you still need to learn about them because many standard library functions raise them.

Some functions exist in both pure and exception-raising variants. For example, apart from `List.find_opt`,
there's also `List.find : ('a -> bool) -> 'a list -> 'a` function that will raise `Not_found` exception
if it failes to find anything:

```ocaml
let () = 
  let x = List.find (fun x -> x mod 2 = 0) [1; 3; 5] in
  Printf.printf "%d\n" x
```

In OCaml, exceptions are not objects, and there are no exception hierarchies. It may look unusual now,
but in fact exceptions predate the rise of object oriented languages and it's more in line with original
implementations. The advantage is that they are very lightweight.

The syntax for defining exceptions is reminiscent of sum types with a single data constructor.
Exception constructors can be either nullary or can have a value of any type attached to them.

All exceptions are essentially members of a single extensible (_open_) sum type _exn_, with some language
magic to allow raising and catching them.

This is how you can define new exceptions:

```ocaml
exception Access_denied

exception Invalid_value of string

(* Parse error: line, column, error message *)
exception Parse_error of (int * int * string)
```

### Raising and catching exceptions

Built-in the division functions `/` and `/.` raise a `Division_by_zero` exception when the divisor is zero.

To learn how to raise an exception ourselves, we can reimplement a division function to raise our own exception.
They are raised using the `raise : exn -> 'a` function:

```ocaml
exception Invalid_value of string

let (//) x y =
  if y <> 0 then x / y
  else raise (Invalid_value "Attempted division by zero")
```

Now let's learn how to catch exceptions. Instead of inventing our own exception, we will use
a built-in exception named `Division_by_zero`:

```ocaml
let () =
  try
    let x = 4 / 0 in
    Printf.printf "%d\n" x
  with Division_by_zero -> print_endline "Cannot divide by zero"
```

Note that `try ... with` constructs are expressions rather than statements, and can be easily used
inside `let`-bindings, for example to provide a default value in case an exception is raised:

```ocaml
let x = try 4 / 0 with Division_by_zero -> 0 (* x = 0 *)

let () = Printf.printf "%d\n" x
```

Another implication of the fact that `try ... with` is an expression is that all expressions in the
`try` and `with` clauses must have the same type. This would cause a type error:

```invalid-ocaml
let x = try 4 / 0 with Division_by_zero -> print_endline "Division by zero"
```

You can catch multiple exceptions using a syntax similar to that of `match` expressions:

```ocaml
let () =
  try
    let x = 4 / 0 in
    Printf.printf "%d\n" x
  with
    Failure s -> print_endline s
  | Division_by_zero -> print_endline "Division by zero"

```

So far our examples assumed that we know all exceptions our functions can possibly raise, or do not want
to catch any other exceptions, which is not always the case. Since there are no exception hierarchies,
we cannot catch a generic exception, but we can use the wildcard pattern to catch any possible exception.
The downside of course is that if even if an exception comes with an attached value, we cannot destructure
it and extract the value since the type of that value is not known in advance.

```ocaml
let () =
  try
    let x = 4 / 0 in
    Printf.printf "%d\n" x
  with
    Division_by_zero -> print_endline "Cannot divide by zero"
  | _ -> print_endline "Something went wrong"

```

### Built-in exceptions

These are some exceptions that are commonly raised by standard library functions and you'll likely encounter them often:

```ocaml
exception Not_found

exception Failure of string

exception Sys_error of string

exception Match_failure of string * int * int
```

The `Not_found` and `Failure` exceptions are normally used to signal error conditions caused by user input. They are expected to be caught.

The `Sys_error` exception is commonly raised by functions that call the operating system, for example you will get it when trying
to open a file that doesn't exist or that you have no permission to read.

The `Match_failure` exception is rather more special. It is raised when pattern matching is not exhaustive and the function hits the unhandled case.
The compiler will always warn you that your pattern matching is not exhaustive, but as we discussed earlier, the checking algorithm
can sometimes incorrectly assume that it's not exhaustive when it actually is, so by default it is a warning rather than error.
But if the compiler was right, it will cause runtime errors, ending with `Match_failure`. Encountering that exception thus indicates
a programming error and supressing it with exception handling is never the right thing to do—if you genuinely do not care about remaining
cases, you should indicate it explicitly by adding a wildcard match clause.

### The types of exception-raising functions

As you've already seen, it's impossible to know if a function raises any exceptions just from its type.
That's the advantage of exceptions: you don't need to deal with unwrapping anything, and if you don't want to handle
them, you can just let them pass and crash the program. It may be even better than the result type for dealing with
unexpected errors, since it allows you to find out where exactly in the program it happened.

<div class="info">
By default only the exception type is shown, but you can get an exception trace with line numbers by running a program
with `OCAMLRUNPARAM=b` environment variable.
</div>

The raise function has type `exn -> 'a`. This is unusual because the type `'a` doesn't appear in the left-hand side
of the arrow. It's a function from the type `exn` to any other type.

The `exit : int -> 'a` function has similar type. It takes an exit code value and terminates the program with it.

The key to understanding this is not thinking what return type a function has, but rather what type can be
substituted for the type variable without compromising type safety. Since `raise` and `exit` abandon the current
computation, and no other function receives their return value, there is no chance anything may get a value
of an unexpected type from it. This is why it has a free type variable in the right hand side—it isn't
_runtime safe_, but type safety is unaffected by exceptions.

Generalizations of exceptions that can be reflected in function types and automatically checked is an area
of active research.


