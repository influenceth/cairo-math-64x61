%lang starknet

from starkware.cairo.common.math import sqrt, sign, abs_value, unsigned_div_rem, assert_not_zero
from math_64x61 import ONE, mul_fp, div_fp, sqrt_fp, exp_fp, ln_fp, assert_64x61

const PI = 7244019458077122842
const HALF_PI = 3622009729038561421

# Calculates hyperbolic sine of x (fixed point)
@view
func sinh_fp {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (ex) = exp_fp(x)
    let (ex_i) = div_fp(ONE, ex)
    let (res) = div_fp(ex - ex_i, 2 * ONE)
    assert_64x61(res)
    return (res)
end

# Calculates hyperbolic cosine of x (fixed point)
@view
func cosh_fp {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (ex) = exp_fp(x)
    let (ex_i) = div_fp(ONE, ex)
    let (res) = div_fp(ex + ex_i, 2 * ONE)
    assert_64x61(res)
    return (res)
end

# Calculates hyperbolic tangent of x (fixed point)
@view
func tanh_fp {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (ex) = exp_fp(x)
    let (ex_i) = div_fp(ONE, ex)
    let (res) = div_fp(ex - ex_i, ex + ex_i)
    assert_64x61(res)
    return (res)
end

# Calculates inverse hyperbolic sine of x (fixed point)
@view
func asinh_fp {range_check_ptr} (x: felt) -> (res: felt):
    let (x2) = mul_fp(x, x)
    let (root) = sqrt_fp(x2 + ONE)
    let (res) = ln_fp(x + root)
    assert_64x61(res)
    return (res)
end

# Calculates inverse hyperbolic cosine of x (fixed point)
@view
func acosh_fp {range_check_ptr} (x: felt) -> (res: felt):
    let (x2) = mul_fp(x, x)
    let (root) = sqrt_fp(x2 - ONE)
    let (res) = ln_fp(x + root)
    assert_64x61(res)
    return (res)
end

# Calculates inverse hyperbolic tangent of x (fixed point)
@view
func atanh_fp {range_check_ptr} (x: felt) -> (res: felt):
    let (_ln_arg) = div_fp(ONE + x, ONE - x)
    let (_ln) = ln_fp(_ln_arg)
    let (res) = div_fp(_ln, 2 * ONE)
    assert_64x61(res)
    return (res)
end
