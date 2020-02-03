# Arithmetics

Now that we know how to use expressions and bindings and have basic idea of how function types work, we can look at
the arithmetics.

As we've seen earlier, integer and floating point numbers are distinct types in OCaml. The character type is not
a numeric type and cannot be used in arithmetic expressions.

An unusual feature of OCaml is that it uses different sets of arithmetic functions for integers and floating point
numbers. The reason for it is that otherwise the language would require either support for ad hoc polymorphism,
which would ruin the decidable type inference without any type annotations; or magical overloading specially for
arithmetics. The language designers sacrificed some convenience for consistency.

The integer operators look as usual: `+`, `-`, `*`, `/`. The floating point operators have a dot at the end:
`+.`, `-.`, `*.`, `/.`.

Remember to always use dotted operators with floating point numbers, and write integer numbers with a dot at the end
like `4.` (or use `4.0`)  to let the compiler know they are supposed to be floats:

```ocaml
let a = 4 + 2 (* good *)
let b = 4.0 *. 3.5 (* good *)

let c = (float 4) +. 2. (* good, integer is converted to float *)
```

Bad examples:

```
let d = 4.0 + 2.0 (* bad, using integer addition with floats *)
let e = 4 +. 2 (* bad using floating point addition with integers *)
let f = 4.0 + 2 (* bad, mixing floats with integers *)
```

Now let's write a program that takes temperature in Celsius from the standard input
and converts it to Kelvin.

```ocaml
let celsius = read_float ()

let kelvin = celsius +. 273.15

let () = print_float kelvin; print_newline ()
```

Let's verify that it works:

```
$ ocamlopt -o kelvin ./kelvin.ml 

$ ./kelvin
20
293.15
```

# Exercises

Write a program that takes an integer from the standard input and prints its square. Use `read_int` function
for reading and `print_int` for writing.

Write a program that takes a floating point number representing temperature in Celsius from the standard input and 
converts it to Fahrenheit.

