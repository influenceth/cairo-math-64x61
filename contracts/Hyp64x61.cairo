%lang starknet

from Math64x61 import (
    Math64x61_ONE,
    Math64x61_mul,
    Math64x61_div,
    Math64x61_sqrt,
    Math64x61_exp,
    Math64x61_ln,
    Math64x61_assert64x61
)

# Calculates hyperbolic sine of x (fixed point)
func Hyp64x61_sinh {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (ex) = Math64x61_exp(x)
    let (ex_i) = Math64x61_div(Math64x61_ONE, ex)
    let (res) = Math64x61_div(ex - ex_i, 2 * Math64x61_ONE)
    Math64x61_assert64x61(res)
    return (res)
end

# Calculates hyperbolic cosine of x (fixed point)
func Hyp64x61_cosh {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (ex) = Math64x61_exp(x)
    let (ex_i) = Math64x61_div(Math64x61_ONE, ex)
    let (res) = Math64x61_div(ex + ex_i, 2 * Math64x61_ONE)
    Math64x61_assert64x61(res)
    return (res)
end

# Calculates hyperbolic tangent of x (fixed point)
func Hyp64x61_tanh {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (ex) = Math64x61_exp(x)
    let (ex_i) = Math64x61_div(Math64x61_ONE, ex)
    let (res) = Math64x61_div(ex - ex_i, ex + ex_i)
    Math64x61_assert64x61(res)
    return (res)
end

# Calculates inverse hyperbolic sine of x (fixed point)
func Hyp64x61_asinh {range_check_ptr} (x: felt) -> (res: felt):
    let (x2) = Math64x61_mul(x, x)
    let (root) = Math64x61_sqrt(x2 + Math64x61_ONE)
    let (res) = Math64x61_ln(x + root)
    Math64x61_assert64x61(res)
    return (res)
end

# Calculates inverse hyperbolic cosine of x (fixed point)
func Hyp64x61_acosh {range_check_ptr} (x: felt) -> (res: felt):
    let (x2) = Math64x61_mul(x, x)
    let (root) = Math64x61_sqrt(x2 - Math64x61_ONE)
    let (res) = Math64x61_ln(x + root)
    Math64x61_assert64x61(res)
    return (res)
end

# Calculates inverse hyperbolic tangent of x (fixed point)
func Hyp64x61_atanh {range_check_ptr} (x: felt) -> (res: felt):
    let (_ln_arg) = Math64x61_div(Math64x61_ONE + x, Math64x61_ONE - x)
    let (_ln) = Math64x61_ln(_ln_arg)
    let (res) = Math64x61_div(_ln, 2 * Math64x61_ONE)
    Math64x61_assert64x61(res)
    return (res)
end
