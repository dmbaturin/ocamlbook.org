# Boolean values and conditional expressions

We already know that `true` and `false` are constants of the type `bool`.
Let's learn how to use them.

## Equality and comparison operators

OCaml provides the following equality and comparison operators: `=` (equal), `<>` (not equal),
and the obvious `<`, `>`, `<=`, `>=`.

Unlike arithmetic operators, they do work with values of any type, but the values on the left and
right hand side of the operator must be of the same type. Trying to compare values of different types
will cause a compilation error. The type of those functions is an interesting question, for now we will only say that all equality and
comparison expressions evaluate to `bool`. 

```
2 = 2 (* good *)
4 <> 3 (* good *)

4 > 2 (* good *)
4 <= 5.0 (* bad, comparing int with float *)
(float 4) <= 5.0 (* good, int converted to float *)

(int_of_float 5.5) = 5 (* good *)
(ceil 5.7) = 6 (* good *)
```

## Conditional expressions

The syntax of the conditional expression is `if <cond> then <expr> else <expr>`.
They are exactly expressions rather than statements, similar to the `<cond> ? <expr> : <expr>`
construct in the C language family.

Since evaluation of expressions may produce side effects, nothing prevents us from using
it in both &ldquo;expression&rdquo; and &ldquo;statement&rdquo; roles, where other languages may require conditional statements and condition expressions
for different situations.

We can use it inside a `let`-binding to save evaluation result in a variable:
```
let a = if (2 = 2) then 0 else 1
```

Or we can use a `let`-expression with a wildcard (`_`) or unit pattern to ignore its result where another language
would use a conditional statement:

```
let n = read_int ()

let () =
  if (n > 100) then print_endline "This is a large number"
  else print_endline "This is a small number"
```

Note that parentheses around the condition are optional and were added for readability.

## No implicit conversion to `bool`

You should remember that there is no implicit conversion to `bool` for any values.
The `<cond>` expression must be a `bool`.

None of these conditional expressions are valid:

```
if 1 then "one" else "two'

if "" then 0 else 1
```
