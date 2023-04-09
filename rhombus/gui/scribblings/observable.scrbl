#lang scribble/rhombus/manual
@(import: "common.rhm" open)

@title{Observables}

@doc(
  class Obs(handle):
    constructor (v,
                 ~name: name :: String = "anon",
                 ~is_derived = #false)
    
  annot.macro 'Obs.of($annot)'
  annot.macro 'MaybeObs.of($annot)'
){

 An @deftech{observable} corresponds to @rhombus(#{obs?}) from
 @rhombusmodname(racket/gui/easy).

 The annotation @rhombus(#,(@rhombus(Obs.of, ~annot))(annot)) is
 satisfied by an annotation whose current value satisfies
 @rhombus(annot). The annotation
 @rhombus(#,(@rhombus(MaybeObs.of, ~annot))(annot)) is satisfied by a
 value that satisfies either @rhombus(annot) or
 @rhombus(#,(@rhombus(Obs.of, ~annot))(annot)).

}

@doc(
  property Obs.value(obs :: Obs)
  property Obs.value(obs :: Obs, v :: Any)
){

 Returns the value via @rhombus(Obs.peek) (which you shouldn't normally
 do) or updates the value via @rhombus(Obs.update) (ignoring the current
 value).

@examples(
  ~hidden:
    // fake observable, because we can't instante `rhombus/gui` here
    class Obs(mutable v):
      property | value: v
               | value := x: v := x
  ~defn:
    def o = Obs("apple")
  ~repl:
    o.value
    o.value := "banana"
    o.value
)

}


@doc(
  method Obs.observe(obs :: Obs, f :: Function.of_arity(1))
){

 Adds @rhombus(f) as a function to be called when the value of
 @rhombus(obs) changes.

}

@doc(
  method Obs.unobserve(obs :: Obs, f :: Function.of_arity(1))
){

 Removes @rhombus(f) as a function to be called when the value of
 @rhombus(obs) changes.

}

@doc(
  method Obs.update(obs :: Obs, f :: Function.of_arity(1))
){

 Changes the value @rhombus(v, ~var) of @rhombus(obs) to
 @rhombus(f(#,(@rhombus(v, ~var)))).

}

@doc(
  method Obs.peek(obs :: Obs)
){

 Returns the current value of @rhombus(obs).

 Normally, instead of peeking an observable's value, you should either
 register an observer or pass an observer to a constructor that expects
 one. For example, when an observer's value should affect drawing in a
 @rhombus(Canvas, ~class), then the first argument to
 @rhombus(Canvas, ~class) should the observer (or one derived from it),
 and then a rendered canvas will be updated when the observable changes.

}

@doc(
  method Obs.rename(obs :: Obs, name :: String) :: Obs
){

 Returns an observer like @rhombus(obs), but named as @rhombus(name).

}

@doc(
  method Obs.map(obs :: Obs, f :: Function.of_arity(1)) :: Obs
){

 Returns an observer whose value changes each time that @rhombus(obs)'s
 value changes, where the new observer's value is changed to
 @rhombus(f(#,(@rhombus(v, ~var)))) when @rhombus(obs) is changed to
 @rhombus(v, ~var).

}

@doc(
  method Obs.debounce(obs :: Obs,
                      ~duration: msec :: NonnegInt = 200) :: Obs
){

 Returns a new observable whose value changes to the value of
 @rhombus(obs) when there is at least a @rhombus(msec) millisecond pause
 in changes to @rhombus(obs).

}

@doc(
  method Obs.throttle(obs :: Obs,
                      ~duration: msec :: NonnegInt = 200) :: Obs
){

 Returns a new observable whose value changes to the value of
 @rhombus(obs) at most once per @rhombus(msec) milliseconds.

}

@doc(
  method Obs.combine(f :: Function.of_arity(1), obs :: Obs, ...) :: Obs
  method Obs.combine({#,(@rhombus(key, ~var)): obs :: Obs, ...}) :: Obs
){

 Returns a new observable whose value changes to the value of
 @rhombus(f(#,(@rhombus(v, ~var)), ...)) or
 @rhombus({#,(@rhombus(key, ~var)): #,(@rhombus(v, ~var)), ...}) when any value @rhombus(v, ~var)
 of an @rhombus(obs) changes.

}