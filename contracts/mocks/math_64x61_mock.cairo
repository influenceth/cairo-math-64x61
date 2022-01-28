%lang starknet

from math_64x61 import mul_fp, div_fp, pow_fp, sqrt_fp, exp2_fp, exp_fp, log2_fp, ln_fp, log10_fp

@view
func mul_fp_test {range_check_ptr} (x: felt, y: felt) -> (res: felt):
    let (res) = mul_fp(x, y)
    return (res)
end

@view
func div_fp_test {range_check_ptr} (x: felt, y: felt) -> (res: felt):
    let (res) = div_fp(x, y)
    return (res)
end

@view
func pow_fp_test {range_check_ptr} (x: felt, y: felt) -> (res: felt):
    let (res) = pow_fp(x, y)
    return (res)
end

@view
func sqrt_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = sqrt_fp(x)
    return (res)
end

@view
func exp2_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = exp2_fp(x)
    return (res)
end

# Calculates the natural exponent of x: e^x
@view
func exp_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = exp_fp(x)
    return (res)
end

@view
func log2_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = log2_fp(x)
    return (res)
end

@view
func ln_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = ln_fp(x)
    return (res)
end

@view
func log10_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = log10_fp(x)
    return (res)
end