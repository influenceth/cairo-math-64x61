%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.math_cmp import is_le, is_not_zero
from starkware.cairo.common.pow import pow
from starkware.cairo.common.math import (
    assert_le,
    assert_lt,
    sqrt,
    sign,
    abs_value,
    signed_div_rem,
    unsigned_div_rem,
    assert_not_zero
)

const INT_PART = 2 ** 64
const FRACT_PART = 2 ** 61
const BOUND = 2 ** 125
const ONE = 1 * FRACT_PART
const E = 6267931151224907085
const PI = 7244019458077122842
const HALF_PI = 3622009729038561421

func assert_64x61 {range_check_ptr} (x: felt):
    assert_le(x, BOUND)
    assert_le(-BOUND, x)
    return ()
end

func to64x61 {range_check_ptr} (x: felt) -> (res: felt):
    assert_le(x, INT_PART)
    assert_le(-INT_PART, x)
    return (x * FRACT_PART)
end

func from64x61 {range_check_ptr} (x: felt) -> (res: felt):
    let (res, _) = signed_div_rem(x, FRACT_PART, BOUND)
    return (res)
end

# Multiples two fixed point values and checks for overflow before returning
@view
func mul_fp {range_check_ptr} (x: felt, y: felt) -> (res: felt):
    tempvar product = x * y
    let (res, _) = signed_div_rem(product, FRACT_PART, BOUND)
    assert_64x61(res)
    return (res)
end

# Divides two fixed point values and checks for overflow before returning
# Both values may be signed (i.e. also allows for division by negative b)
@view
func div_fp {range_check_ptr} (x: felt, y: felt) -> (res: felt):
    alloc_locals
    let (div) = abs_value(y)
    let (div_sign) = sign(y)
    tempvar product = x * FRACT_PART
    let (ures, _) = signed_div_rem(product, div, BOUND)
    assert_64x61(ures)
    return (res = ures * div_sign)
end

# Calclates the value of x^y and checks for overflow before returning
# x is a 64x61 fixed point value
# y is a standard felt (int)
@view
func pow_fp {range_check_ptr} (x: felt, y: felt) -> (res: felt):
    alloc_locals
    let (exp_sign) = sign(y)
    let (exp_val) = abs_value(y)

    if exp_sign == 0:
        return (ONE)
    end

    if exp_sign == -1:
        let (num) = pow_fp(x, exp_val)
        return div_fp(ONE, num)
    end

    let (half_exp, rem) = unsigned_div_rem(exp_val, 2)
    let (half_pow) = pow_fp(x, half_exp)
    let (pres) = mul_fp(half_pow, half_pow)

    if rem == 0:
        assert_64x61(pres)
        return (pres)
    else:
        let (res) = mul_fp(pres, x)
        assert_64x61(res)
        return (res)
    end
end

# Calculates the square root of a fixed point value
# x must be positive
@view
func sqrt_fp {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals
    let (root) = sqrt(x)
    let (scale_root) = sqrt(FRACT_PART)
    let (res, _) = signed_div_rem(root * FRACT_PART, scale_root, BOUND)
    assert_64x61(res)
    return (res)
end

# Calculates the most significant bit where x is a fixed point value
# TODO: use binary search to improve performance
func _msb {range_check_ptr} (x: felt) -> (res: felt):
    let (cmp) = is_le(x, FRACT_PART)

    if cmp == 1:
        return (0)
    end

    let (div, _) = unsigned_div_rem(x, 2)
    let (rest) = _msb(div)
    let res = 1 + rest
    return (res)
end

# Calculates the binary exponent of x: 2^x
@view
func exp2_fp {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (exp_sign) = sign(x)

    if exp_sign == 0:
        return (ONE)
    end

    let (exp_value) = abs_value(x)
    let (int_part, frac_part) = unsigned_div_rem(exp_value, FRACT_PART)
    let (int_res) = pow_fp(2 * ONE, int_part)

    # 1.069e-7 maximum error
    const a1 = 2305842762765193127
    const a2 = 1598306039479152907
    const a3 = 553724477747739017
    const a4 = 128818789015678071
    const a5 = 20620759886412153
    const a6 = 4372943086487302

    let (r6) = mul_fp(a6, frac_part)
    let (r5) = mul_fp(r6 + a5, frac_part)
    let (r4) = mul_fp(r5 + a4, frac_part)
    let (r3) = mul_fp(r4 + a3, frac_part)
    let (r2) = mul_fp(r3 + a2, frac_part)
    local frac_res = r2 + a1

    let (ures) = mul_fp(int_res, frac_res)
    
    if exp_sign == -1:
        return div_fp(ONE, ures)
    else:
        return (ures)
    end
end

# Calculates the natural exponent of x: e^x
@view
func exp_fp {range_check_ptr} (x: felt) -> (res: felt):
    const mod = 3326628274461080623
    let (bin_exp) = mul_fp(x, mod)
    let (res) = exp2_fp(bin_exp)
    return (res)
end

# Calculates the binary logarithm of x: log2(x)
# x must be greather than zero
@view
func log2_fp {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    if x == ONE:
        return (0)
    end

    let (is_frac) = is_le(x, FRACT_PART - 1)

    # Compute negative inverse binary log if 0 < x < 1
    if is_frac == 1:
        let (div) = div_fp(ONE, x)
        let (ires) = log2_fp(div)
        return (-ires)
    end

    let (x_over_two, _) = unsigned_div_rem(x, 2)
    let (b) = _msb(x_over_two)
    let (divisor) = pow(2, b)
    let (norm, _) = unsigned_div_rem(x, divisor)

    # 2.773e-7 maximum error
    const a1 = -7483700926368029834
    const a2 = 16449814641801457351
    const a3 = -17280288391508907035
    const a4 = 13331091805175516488
    const a5 = -6882990609484111548
    const a6 = 2255333401508833754
    const a7 = -424135990449832908
    const a8 = 34876708657633277

    let (r8) = mul_fp(a8, norm)
    let (r7) = mul_fp(r8 + a7, norm)
    let (r6) = mul_fp(r7 + a6, norm)
    let (r5) = mul_fp(r6 + a5, norm)
    let (r4) = mul_fp(r5 + a4, norm)
    let (r3) = mul_fp(r4 + a3, norm)
    let (r2) = mul_fp(r3 + a2, norm)
    local norm_res = r2 + a1

    let (int_part) = to64x61(b)
    local res = int_part + norm_res
    return (res)
end

# Calculates the natural logarithm of x: ln(x)
# x must be greater than zero
@view
func ln_fp {range_check_ptr} (x: felt) -> (res: felt):
    const ln_2 = 1598288580650331957
    let (log2_x) = log2_fp(x)
    let (product) = mul_fp(log2_x, ln_2)
    return (product)
end

# Calculates the base 10 log of x: log10(x)
# x must be greater than zero
@view
func log10_fp {range_check_ptr} (x: felt) -> (res: felt):
    const log10_2 = 694127911065419642
    let (log10_x) = log2_fp(x)
    let (product) = mul_fp(log10_x, log10_2)
    return (product)
end

# Helper function to calculate Taylor series for sin
func _sin_fp_loop {range_check_ptr} (x: felt, i: felt, acc: felt) -> (res: felt):
    alloc_locals

    if i == -1:
        return (acc)
    end

    let (num) = mul_fp(x, x)
    local div = (2 * i + 2) * (2 * i + 3) * FRACT_PART
    let (t) = div_fp(num, div)
    let (t_acc) = mul_fp(t, acc)

    let (next) = _sin_fp_loop(x, i - 1, ONE - t_acc)
    return (next)
end

# Calculates sin(x) with x in radians (fixed point)
@view
func sin_fp {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (sign1) = sign(x) # extract sign
    let (abs1) = abs_value(x)
    let (_, x1) = unsigned_div_rem(abs1, 2 * PI)
    let (rem, x2) = unsigned_div_rem(x1, PI)
    local sign2 = 1 - (2 * rem)
    let (acc) = _sin_fp_loop(x2, 5, ONE)
    let (res2) = mul_fp(x2, acc)
    local res = res2 * sign1 * sign2
    return (res)
end

# Calculates cos(x) with x in radians (fixed point)
@view
func cos_fp {range_check_ptr} (x: felt) -> (res: felt):
    tempvar shifted = HALF_PI - x
    let (res) = sin_fp(shifted)
    return (res)
end

# Calculates tan(x) with x in radians (fixed point)
@view
func tan_fp {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (sinx) = sin_fp(x)
    let (cosx) = cos_fp(x)
    assert_not_zero(cosx)
    let (res) = div_fp(sinx, cosx)
    return (res)
end

# Calculates arctan(x) (fixed point)
# See https://stackoverflow.com/a/50894477 for range adjustments
@view
func atan_fp {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    const sqrt3_3 = 1331279082078542925 # sqrt(3) / 3
    const pi_6 = 1207336576346187140 # pi / 6
    const p_7 = 1614090106449585766 # 0.7
    
    # Calculate on positive values and re-assign later
    let (_sign) = sign(x)
    let (abs_x) = abs_value(x)

    # Invert value when x > 1
    let (_invert) = is_le(ONE, abs_x)
    local x1a_num = abs_x * (1 - _invert) + _invert * ONE
    local x1a_div = abs_x * _invert + ONE - ONE * _invert
    let (x1a) = div_fp(x1a_num, x1a_div)

    # Account for lack of precision in polynomaial when x > 0.7
    let (_shift) = is_le(p_7, x1a)
    local b = sqrt3_3 * _shift + ONE - _shift * ONE
    local x1b_num = x1a - b
    let (x1b_div_2) = mul_fp(x1a, b)
    local x1b_div = ONE + x1b_div_2
    let (x1b) = div_fp(x1b_num, x1b_div)
    local x1 = x1a * (1 - _shift) + x1b * _shift

    # 5.242e-7 maximum error
    const a1 = 1208801451666
    const a2 = 2305693433466554256
    const a3 = 2963328028465977
    const a4 = -789082839276858396
    const a5 = 53632802362123506
    const a6 = 456545008278073597
    const a7 = -222313812691352603

    let (r7) = mul_fp(a7, x1)
    let (r6) = mul_fp(r7 + a6, x1)
    let (r5) = mul_fp(r6 + a5, x1)
    let (r4) = mul_fp(r5 + a4, x1)
    let (r3) = mul_fp(r4 + a3, x1)
    let (r2) = mul_fp(r3 + a2, x1)
    local z1 = r2 + a1

    # Adjust for sign change, inversion, and shift
    local z2 = z1 + (pi_6 * _shift)
    local z3 = (z2 - (HALF_PI * _invert)) * (1 - _invert * 2)
    local z4 = z3 * _sign
    return (z4)
end