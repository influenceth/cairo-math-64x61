[![npm version](https://badge.fury.io/js/@influenceth%2Fcairo-math-64x61.svg)](https://badge.fury.io/js/@influenceth%2Fcairo-math-64x61)

# Cairo Math 64x61

A fixed point 64.61 math library for Cairo & Starknet

## Usage ##
For use with `starknet-hardhat-plugin`, install via npm with `npm install --save-dev @influenceth/cairo-math-64x61` and add `./node_modules/@influenceth/cairo-math-64x61` to `cairoPaths` in your hardhat config (see https://github.com/Shard-Labs/starknet-hardhat-plugin#paths). Then you can import with, for example: `from contracts.Math64x61 import Math64x61_mul`

## Signed 64.61 Fixed Point Numbers ##
A signed 64.61-bit fixed point number is a fraction in which the numerator is a signed 125-bit integer and the denominator is 2^61. Since the denominator stays the same there is no need to store it (as in a floating point value).

64.61 is utilized as the 125 bit representation allows for overflow up to 2^125 * 2^125 (250 bits) during calculation taking advantage of Cairo's 251 bit felts.

Can represent values in the range of -2^64 to 2^64 with precision to 4.34e-19.

## Standard Library ##
`Math64x61` includes implementation of `add`, `sub`, `mul`, `div`, `sqrt`, `exp`, `ln`, `log2`, `log10`, and `pow` as well as conversion to / from felts and Uint256 values, `floor`, `ceil`, `min`, `max` and assertion methods.

## Trigonometry Library ##
`Trig64x61` includes implementation of `sin`, `cos`, `tan` and their inverses.

## Hyperbolic Library ##
`Hyp64x61` includes implementation of `sinh`, `cosh`, `tanh`, and their inverses.

## Vector Library ##
`Vec64x61` includes implementation of vector arithmetic (`add`, `sub`, `div`), dot product (`dot`), cross product (`cross`) and `norm`.

## Extensibility ##
This library strives to adhere to the OpenZeppelin extensibility pattern: https://github.com/OpenZeppelin/cairo-contracts/blob/main/docs/Extensibility.md
