%lang starknet

from Math64x61 import (
    Math64x61_mul,
    Math64x61_div,
    Math64x61_pow,
    Math64x61_sqrt,
    Math64x61_exp2,
    Math64x61_exp,
    Math64x61_log2,
    Math64x61_ln,
    Math64x61_log10
)

@view
func Math64x61_mul_test {range_check_ptr} (x: felt, y: felt) -> (res: felt):
    let (res) = Math64x61_mul(x, y)
    return (res)
end

@view
func Math64x61_div_test {range_check_ptr} (x: felt, y: felt) -> (res: felt):
    let (res) = Math64x61_div(x, y)
    return (res)
end

@view
func Math64x61_pow_test {range_check_ptr} (x: felt, y: felt) -> (res: felt):
    let (res) = Math64x61_pow(x, y)
    return (res)
end

@view
func Math64x61_pow_frac_test {range_check_ptr} (x: felt, y: felt) -> (res: felt):
    let (res) = Math64x61_pow_frac(x, y)
    return (res)
end

@view
func Math64x61_sqrt_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Math64x61_sqrt(x)
    return (res)
end

@view
func Math64x61_exp2_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Math64x61_exp2(x)
    return (res)
end

# Calculates the natural exponent of x: e^x
@view
func Math64x61_exp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Math64x61_exp(x)
    return (res)
end

@view
func Math64x61_log2_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Math64x61_log2(x)
    return (res)
end

@view
func Math64x61_ln_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Math64x61_ln(x)
    return (res)
end

@view
func Math64x61_log10_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Math64x61_log10(x)
    return (res)
end
