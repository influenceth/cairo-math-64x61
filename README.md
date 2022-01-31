# Cairo Math 64x61

A fixed point 64.61 math library for Cairo & Starknet

## Signed 64.61 Fixed Point Numbers ##
A signed 64.61-bit fixed point number is a fraction in which the numerator is a signed 125-bit integer and the denominator is 2^61. Since the denominator stays the same there is no need to store it (as in a floating point value).

64.61 is utilized as the 125 bit representation allows for overflow up to 2^125 * 2^125 (250 bits) during calculation taking advantage of Cairo's 251 bit felts.

Can represent values in the range of -2^64 to 2^64 with precision to 4.34e-19.

## Standard Library ##
`Math64x61` includes implementation of `mul`, `div`, `sqrt`, `exp`, `ln`, `log2`, `log10`, and `pow` as well as conversion and assertion methods.

## Trigonometry Library ##
`Trig64x61` includes implementation of `sin`, `cos`, `tan` and their inverses.

## Hyperbolic Library ##
`Hyp64x61` includes implementation of `sinh`, `cosh`, `tanh`, and their inverses.

## Extensibility ##
This library strives to adhere to the OpenZeppelin extensibility pattern: https://github.com/OpenZeppelin/cairo-contracts/blob/main/docs/Extensibility.md
