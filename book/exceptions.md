# Exceptions

In OCaml, exceptions are not objects, and there are no exception hierarchies. It may look unusual now,
but in fact exceptions predate the rise of object oriented languages and it's more in line with original
implementations. The advantage is that they are very lightweight.

The syntax for defining exceptions is reminiscent of sum types with a single data constructor.
The data constructors can be either nullary or can have a value of any type attached to them.

All exceptions are essentially members of a single extensible (_open_) sum type _exn_, with some language
magic to allow raising and catching them.

This is how you can define new exceptions:

```
exception Access_denied

exception Invalid_value of string
```

## Raising and catching exceptions

It is important to learn how to use exceptions because many functions from the standard library and third party
libraries alike use them, and it's impossible to avoid them even if you prefer to write your own code in
purely functional style.

For example, the division functions `/` and `/.` raise a `Division_by_zero` exception when the divisor is zero.

To learn how to raise an exception ourselves, we can reimplement the `/` function to raise our own exception.
They are raised using the `raise : exn -> 'a` function:

```
exception Invalid_value of string

let (//) x y =
  if y <> 0 then x / y
  else raise (Invalid_value "Attempted division by zero")
```

Now let's learn how to catch exceptions:

```
let () =
  try
    let x = 4 // 0 in
    Printf.printf "%d\n" x
  with Invalid_value s -> print_endline s
```

Note that `try ... with` constructs are expressions rather than statements, and can be easily used
inside `let`-bindings, for example to provide a default value in case an exception is raised:

```
let x = try 4 / 0 with Division_by_zero -> 0 (* x = 0 *)

let () = Printf.printf "%d\n" x
```

Another implication of the fact that `try ... with` is an expression is that all expressions in the
`try` and `with` clauses must have the same type. This would cause a type error:

```
let x = try 4 / 0 with Division_by_zero -> print_endline "Division by zero"
```

You can catch multiple exceptions using a syntax similar to that of `match` expressions:

```
let () =
  try
    let x = 4 // 0 in
    Printf.printf "%d\n" x
  with
    Invalid_value s -> print_endline s
  | Division_by_zero -> print_endline "Division by zero"

```

So far our examples assumed that we know all exceptions our functions can possibly raise, or do not want
to catch any other exceptions, which is not always the case. Since there are no exception hierarchies,
we cannot catch a generic exception, but we can use the wildcard pattern to catch any possible exception.
The downside of course is that if an exception comes with an attached value, we cannot destructure
it and extract the value since the type of that value is not known in advance.

```
let () =
  try
    let x = 4 // 0 in
    Printf.printf "%d\n" x
  with
    Invalid_value s -> print_endline s
  | _ -> print_endline "Something went wrong"

```

### Built-in exceptions

These are some exceptions that are commonly raised by standard library functions and you'll likely encounter them often:

```
exception Not_found

exception Failure of string

exception Sys_error of string

exception Match_failure of string * int * int
```

The `Not_found` and `Failure` exceptions are normally used to signal error conditions caused by user input. They are expected to be caught.

The `Match_failure` exception is rather more special. It is raised when pattern matching is not exhaustive and the function hits the unhandled case.
The compiler will always warn you that your pattern matching is not exhaustive, but as we discussed earlier, the checking algorithm
can sometimes incorrectly assume that it's not exhaustive when it actually is, so by default it is a warning rather than error.
But if the compiler was right, it will cause runtime errors, ending with `Match_failure`. Encountering that exception thus indicates
a programming error and supressing it with exception handling is never the right thing to do &mdash; if you genuinely do not care about remaining
cases, you should indicate it explicitly by adding a wildcard match clause.
