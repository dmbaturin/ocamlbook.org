# Recursive functions

A recursive definition is a definition that refers to itself. It's often said,
that a recursive function is a function that _calls itself_, which
implies that, at the machine level, some memory (specifically, stack space) is used for a function call.

In imperative languages, recursive functions are often discouraged, and people
use them only for tasks that don't have non-recursive solutions, like traversing
directory trees.

Performance and memory consumption is a valid concern if an expression  like `f(f(f(x)))`
always takes three times as much memory as `f(x)`.

In functional languages like OCaml, Haskell, or Scheme, it's not always the case
and it's possible to use even _infinite_ recursion without running out of memory.

That is why in functional languages recursion is used much more often, not only to deal
with recursive data structures, but also as a control flow pattern that plays the same role
as loops in imperative languages.

## Recursive binding syntax

Let's write a function that calculates the factorial of an integer number.
The factorial of zero (written _0!_) is 1, and the factorial of a number _n_ greater than zero
is _n * (n-1)!_.

1. `0! = 1`
2. `n! = n * (n - 1)!`

This is what it will look like:

```
let rec factorial n =
  if n = 0 then 1
  else n * (factorial (n-1))
```
Notice the `rec` keyword. If you want to define a recursive function, you need to use
`let rec` instead of just `let`. That's because OCaml allows you to choose whether
you want the name `factorial` inside that definition to refer to the function itself,
or redefine an older definition.

Remember that in OCaml, functions are values,
and function bindings are not different from variable bindings. Let's see what would
happen if `rec` was the default. Consider this program:

```
let x = 1

let x = x + 10
```

The intent of the second expression is to redefine a previously defined variable `x`
with a new value. However, if `rec` was the default and the compiler naively assumed
that if the name of the binding appears in its body then the binding is supposed to be
recursive, then `x` in `x + 10` would be assumed to be self-referential,
thus making the expression meaningless and ill-types.

The `rec` keyword allows you to control this behaviour. The issue is even more apparent
if you want to redefine a function. Suppose you want to redefine the `print_string`
function to behave like `print_endline`.

```
let print_string s = print_string s; print_newline ()
```

If `rec` was the default, the effect would be even worse. Unlike our previous example,
that code would type check, but instead of intended behaviour, it would be calling our
newly defined `print_string` endlessly, which is absolutely not what we wanted.

You can verify it by adding the `rec` keyword and pasting that line into the REPL:

```
# let rec print_string s = print_string s; print_newline ();;
val print_string : 'a -> unit = <fun>

# print_string "foo";;
Stack overflow during evaluation (looping recursion?).

```

Since `rec` is not the default, our first version of the redefined `print_string`
works as expected. If you write a function that is intended to be recursive but forget the
`rec` keyword, the compiler will complain about unbound name, since by default it requires
that all names must be already defined in the outer scope before they can be referred to.

## Mutually recursive functions

Sometimes you will want your function definitions to be _mutually recursive_, that is, refer
to one another. Real life use cases for it often arise in data parsing and formatting, as well
as many other fields. For example, JSON, objects (dictionaries) may contain arrays and
vice versa, so if you are writing a JSON formatter, your functions for formatting objects
and arrays will need to refer to each other.

The problem with it in OCaml and many other statically typed languages is that all names
must be defined in advance. Some languages use forward declarations to get around that issue.

OCaml allows you to explicitly declare bindings as mutually recursive using the `and` keyword.
Such definitions follow this pattern: `let rec <name1> = <expr> and <name2> = <expr>`.

Let's demonstrate it using a popular contrived example:

```
let rec even x =
  if x = 0 then true
  else odd (x - 1)
and odd x =
  if x = 0 then false
  else even (x - 1)
```

## Recursion as a control structure and tail call optimization

In imperative programming languages, recursion is often avoided unless absolutely
necessary because of its performance and memory consumption impact. It is not an inherent
problem of recursion as such, but rather a limitation of programming language implementations.

In functional languages, including OCaml, those performance issues can be avoided and the compiler
will translate recursive functions to loops, if you follow certain guidelines.

Before we learn the guidelines, let's examine the root cause of memory consumption issues in recursive functions.
Let's re-examine our original factorial definition:

```
let rec factorial n =
  if n = 0 then 1
  else n * (factorial (n-1))
```

Since the expression  `n * (factorial (n-1))` refers to `(factorial (n-1))`, it cannot be evaluated until
the result of executing `(factorial (n-1))` is known. Thus, `factorial 3` will produce four nested function calls
in the executable code. With large arguments it will take up a large amount of stack space, and eventually cause
a stack overflow. 

Now consider this program:

```
let rec loop () = print_endline "I'm a recursive function"; loop ()

let _ = loop ()
```

If you compile and run it or paste it into the REPL, you will notice that it keeps
printing `I'm a recursive function` forever without ever causing a stack overflow.
This is the usual way to write an endless loop in OCaml.

How is it possible? If you look at the `loop` function body, you can see that it doesn't
use the result of `loop ()` in any way. This means it can be evaluated correctly
without knowing the value of `loop ()` from the previous call.

The OCaml compiler knows that, and produces executable code where `loop ()` is translated
to an unconditional jump rather than a function call. 

What if you do need the result of previous function calls? You can introduce an auxilliary
function argument (often called _accumulator_) and pass the result of previous computations
in it. This is often called _passing state around_ and together with function composition,
it's a very common functional programming technique.

The key is to rewrite the function body so that everything the next function call will need
is passed in the accumulator argument.

```
let rec factorial acc n =
  if n = 0 then acc
  else factorial (acc * n) (n - 1)

let () = Printf.printf "%d\n" (factorial 1 5)
```

The additional argument `acc` is multiplied by `n` every time,
the function always knows all the data it needs to calculate
the factorial of `n - 1`, and OCaml also knows that it needs no state data from
previous function calls. The `factorial` function call in the function body is said to be
in the _tail position_.

This implementation is much less convenient to use than the original though, and worse,
the user needs to know the correct initial value of `acc` to use it successfully.
For this reason tail recursive functions are usually implemented as nested functions to give
them convenient interface and hide the added complexity:

```
let factorial n =
  let rec aux acc n =
    if n = 0 then acc
    else aux (acc * n) (n - 1)
  in aux 1 n
```

Assuming _f_ is a recursive function, while _g_, _h_, _i_, and _j_ are some other functions,
you can use these three forms as blueprints for your tail-recursive functions:

```
let rec f acc x = f (g acc x) (h x)

let rec f x =
  if (g x) then f (h acc x) (j x)
  else f (i acc x) (j x)

let rec f x =
  let y = g x in
  f y
```

Or, if we put it another way, if you want your function _f_ to be tail recursive, never use `(f x)`
as an argument of any other function inside the body of _f_.

If you are using Merlin with your editor, it will tell you if an expression is in a tail position or not.
If you want to find out the hard way if compiler recognized a function as tail recursive, you can run `ocamlc -annot myfile.ml`
and look for `call ( tail )` at the required positions. This is how Merlin does it, although it uses the binary
rather than a text annotation format for that.

### Practical limits of naively recursive functions

While the existence of the limit of functions that are not tail recursive is an undeniable fact,
in practice it's important to consider not only its existence, but also its size.

Experimentally tested stack depth limit, checked on an x86-64 and ARMv6 GNU/Linux machines appears to be around 260 000
for bytecode and around 520 000 for native executables. This is enough to safely use recusrive functions even for very
large datastructures, and seriously reduces the benefits of aggressively optimizing recursive functions by
rewriting them in the tail recursive style unless they are intended to run forever or knowingly receive very large inputs.

It is important to learn how to use tail recursion, but it's also important to know when you can get away with a simpler
naively recursive definition.

## Exercises

1. Write a function that checks if given integer number is prime (i.e. has no divisors other than 1 and itself).

2. Write a function that calculates the greatest common divisor of two integer numbers using the Euclides algorithm:
gcd n 0 = n, gcd n m = gcd m, (n mod m). Do it in both naive and tail recursive style.

3. Consider this function for multiplying integer numbers: 

```
let rec mul n m =
  if m = 1 then n
  else n + (mul n (m-1))
```

Rewrite it in the tail-recursive style.

4. Verify that it is indeed tail recursive by using a value of _m_ greater than the call stack depth, e.g. `mul 2 600000`.

5. Write a program that keeps printing "I'm a recursive function" and "I'm also a recursive function",
using separate functions for each of the messages.
