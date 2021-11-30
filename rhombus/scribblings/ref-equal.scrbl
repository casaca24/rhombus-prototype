#lang scribble/rhombus/manual
@(import: "common.rhm": no_prefix)

@title{Equality}

@doc[
  operator ((v1 :: Any) == (v1 :: Any)) :: Boolean
]{

 Reports whether @rhombus[v1] and @rhombus[v2] are equal, which includes
 recursively comparing elements of compound data structures. Two numbers
 are @rhombus[==] only if they are both exact or both inexact.

@examples[
  "apple" == "apple",
  [1, 2, 3] == 1,
  [1, "apple", {"alice": 97}] == [1, "apple", {"alice": 97}],
  1 == 1.0
]

}

@doc[
  operator ((v1 :: Any) === (v1 :: Any)) :: Boolean
]{

 Reports whether @rhombus[v1] and @rhombus[v2] are the same object.
 Being the @emph{same} is weakly defined, but only @rhombus[==] values
 can possibly be the same object, and mutable values are the same only if
 modifying one has the same effect as modifying the other. Interned
 values like symbols are @rhombus[===] when they are @rhombus[==].

@examples[
  symbol(apple) === symbol(apple),
  symbol(apple) === symbol(banana),
]

}

@doc[
  operator ((x :: Number) .= (y :: Number)) :: Boolean
]{

 Reports whether @rhombus[x] and @rhombus[y] are numerically equal,
 where inexact numbers are effectively coerced to exact for comparisions
 to exact numbers.

@examples[
  1 .= 1,
  1 .= 2,
  1.0 .= 1
]

}


@doc[
  expr.macro '(=)
]{

 The @rhombus[=] operator is not bound as an expression or binding
 operator. It is used as a syntactic delimiter by various forms, such as
 in @rhombus[fun] when specifying the default value for an optional
 argument.

}
