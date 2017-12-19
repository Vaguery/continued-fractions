## Why

This is a series of explorations (in Ruby and Rspec 3) in support of a genetic programming benchmark problem I'm considering.

## What

A tiny class called `ContinuedFraction` which takes a splatted array of numbers as a constructor, and which does some simple arithmetic to evaluate those numbers as the constants in a [generalized continued fraction](https://en.wikipedia.org/wiki/Generalized_continued_fraction), where the first value is interpreted as `b_0` (using the Wikipedia notational convention), and the subsequent terms are considered a series of pairs `(a_i,b_i)`.

If no arguments are passed into `ContinuedFraction.new`, the value is assumed to be zero. If an _even_ number of arguments is passed in, the final missing `b_n` value will be assumed to be exactly `1`.

Thus, `ContinuedFraction.new(1,2,3)` represents the value `(1 + 2/3)` (`b_0` and one pair `(2,3)`), but `ContinuedFraction.new(1,2,3,4)` represents the value `(1 + 2/(3+4/1))` (one `b_0` value, and _two_ pairs `(2,3)` and `(4,1)`).

The library includes a `#calculate` method that returns the final value for the entire set of constants, and also a `#convergence` method that returns all intermediate results for every subset of constants `[b_0,a_1...c_i]` for all `i`.

## So?

Next step is to include a simple metaheuristic search that will return a "good enough" approximation of the constants for any given target constant. "Good enough" subject to exploration, which is the point....
