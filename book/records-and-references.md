# Records and references

As we've seen already, combinations of sum and product types can create powerful and expressive abstractions.
However, a product type with too many fields can easily become unwieldy. It may also be difficult to remember what every item means if they are the same type.

This is where records come in handy. They have named fields, so it's easy to convey the meaning of every fields.

OCaml record are similar to records in Pascal or Ada and to C structs. They can have one or more named fields, and every field can be accessed by name.

Record types cannot be anonymous, they must always be defined before use.


## Example

Let's write an example program that deals with 2d vectors defined by their components (x and y):


```ocaml
type vector = { x: float; y: float }

let vec = {x=1; y=1}

let length v =
  (v.x *. v.x) +. (v.y *. v.y) |> sqrt
  
let () =
  Printf.printf "%f\n" (length vec)
```

As you can see, fields can be accessed using the `value.fields` notation.

When you create a new record value, all fields must be defined. Trying to create a partially defined record will cause a compilation error.

Modifying records is a more interesting questions. Unlike imperative languages, OCaml provides two ways to update record fields: functional and destructive.

## Immutable records

In imperative languages, record fields are mutable by default and assigning a new value to a field modifies an existing record irreversibly.

Since OCaml is mainly a functional language, record fields are immutable by default. However, it's possible to create new records without destroying the old ones.

This is called &ldquo;functional update&rdquo;. As we have seen in previous chapter, immutable values can benefit from _structural sharing_. When a new record is created, its original field values are not copied, in memory they are pointers to the old values.

Functional update is done with `with` keyword:

```ocaml
type contact = {name: string; phone: string}

let person = {name="Boris"; phone="2128506"}

let person = {person with phone="212850A" }
``` 

It's fine to update multiple fields at once as well:

```ocaml
let person = {name="Boris"; phone="2128506"}

let person = {person with name="Bob"; phone="212850B" }
```

If you change every field of a record, the compiler will warn you about it:

```
Warning 23: all the fields are explicitly listed in this record: the 'with' clause is useless. 
```

## Mutable fields and destructive updates

Most values in OCaml are immutable, but records is an exception to that rule: they can have _mutable fields_.

Mutable fields are declared and updated using this syntax:

```ocaml
type user = {name: string; mutable password: string}

let user = {name="root"; password=""}

let () = user.password <- "qwerty"
```

Unlike many operators we have seen so far, `<-` is special syntax rather than a normal function, so it cannot be applied partially. Field update expressions like `user.password <- "qwerty"` have type `unit`. 

It's impossible to modify fields this way if they aren't declared as mutable.

## References

Creating a new record type every time you need a mutable variable would quickly become annoying, so OCaml standard library includes very simple syntactic sugar for it.

There's a type `'a ref` that is really a record with a single mutable field named &ldquo;contents&rdquo;. It comes with a function `ref : 'a -> 'a ref` that creates a new reference, and an assignment operator `:=`.

```ocaml
type 'a ref = {mutable contents: 'a}

let ref value = {contents: value}

let (:=) reference value = reference.contents <- value 
```
