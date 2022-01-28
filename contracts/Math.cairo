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
    let (res_u, _) = signed_div_rem(product, div, BOUND)
    assert_64x61(res_u)
    return (res = res_u * div_sign)
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
    let (res_p) = mul_fp(half_pow, half_pow)

    if rem == 0:
        assert_64x61(res_p)
        return (res_p)
    else:
        let (res) = mul_fp(res_p, x)
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
    alloc_locals

    let (cmp) = is_le(x, FRACT_PART)

    if cmp == 1:
        return (0)
    end

    let (div, _) = unsigned_div_rem(x, 2)
    let (rest) = _msb(div)
    local res = 1 + rest
    assert_64x61(res)
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
    tempvar frac_res = r2 + a1

    let (res_u) = mul_fp(int_res, frac_res)
    
    if exp_sign == -1:
        let (res_i) = div_fp(ONE, res_u)
        assert_64x61(res_i)
        return (res_i)
    else:
        assert_64x61(res_u)
        return (res_u)
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
        let (res_i) = log2_fp(div)
        return (-res_i)
    end

    let (x_over_two, _) = unsigned_div_rem(x, 2)
    let (b) = _msb(x_over_two)
    let (divisor) = pow(2, b)
    let (norm, _) = unsigned_div_rem(x, divisor)

    # 4.233e-8 maximum error
    const a1 = -7898418853509069178
    const a2 = 18803698872658890801
    const a3 = -23074885139408336243
    const a4 = 21412023763986120774
    const a5 = -13866034373723777071
    const a6 = 6084599848616517800
    const a7 = -1725595270316167421
    const a8 = 285568853383421422
    const a9 = -20957604075893688

    let (r9) = mul_fp(a9, norm)
    let (r8) = mul_fp(r9 + a8, norm)
    let (r7) = mul_fp(r8 + a7, norm)
    let (r6) = mul_fp(r7 + a6, norm)
    let (r5) = mul_fp(r6 + a5, norm)
    let (r4) = mul_fp(r5 + a4, norm)
    let (r3) = mul_fp(r4 + a3, norm)
    let (r2) = mul_fp(r3 + a2, norm)
    local norm_res = r2 + a1

    let (int_part) = to64x61(b)
    local res = int_part + norm_res
    assert_64x61(res)
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
    tempvar div = (2 * i + 2) * (2 * i + 3) * FRACT_PART
    let (t) = div_fp(num, div)
    let (t_acc) = mul_fp(t, acc)
    let (next) = _sin_fp_loop(x, i - 1, ONE - t_acc)
    return (next)
end

# Calculates sin(x) with x in radians (fixed point)
@view
func sin_fp {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (_sign1) = sign(x) # extract sign
    let (abs1) = abs_value(x)
    let (_, x1) = unsigned_div_rem(abs1, 2 * PI)
    let (rem, x2) = unsigned_div_rem(x1, PI)
    local _sign2 = 1 - (2 * rem)
    let (acc) = _sin_fp_loop(x2, 6, ONE)
    let (res2) = mul_fp(x2, acc)
    local res = res2 * _sign1 * _sign2
    assert_64x61(res)
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
    tempvar x1a_div = abs_x * _invert + ONE - ONE * _invert
    let (x1a) = div_fp(x1a_num, x1a_div)

    # Account for lack of precision in polynomaial when x > 0.7
    let (_shift) = is_le(p_7, x1a)
    local b = sqrt3_3 * _shift + ONE - _shift * ONE
    local x1b_num = x1a - b
    let (x1b_div_2) = mul_fp(x1a, b)
    tempvar x1b_div = ONE + x1b_div_2
    let (x1b) = div_fp(x1b_num, x1b_div)
    local x1 = x1a * (1 - _shift) + x1b * _shift

    # 6.769e-8 maximum error
    const a1 = -156068910203
    const a2 = 2305874223272159097
    const a3 = -1025642721113314
    const a4 = -755722092556455027
    const a5 = -80090004380535356
    const a6 = 732863004158132014
    const a7 = -506263448524254433
    const a8 = 114871904819177193
    
    let (r8) = mul_fp(a8, x1)
    let (r7) = mul_fp(r8 + a7, x1)
    let (r6) = mul_fp(r7 + a6, x1)
    let (r5) = mul_fp(r6 + a5, x1)
    let (r4) = mul_fp(r5 + a4, x1)
    let (r3) = mul_fp(r4 + a3, x1)
    let (r2) = mul_fp(r3 + a2, x1)
    tempvar z1 = r2 + a1

    # Adjust for sign change, inversion, and shift
    tempvar z2 = z1 + (pi_6 * _shift)
    tempvar z3 = (z2 - (HALF_PI * _invert)) * (1 - _invert * 2)
    local res = z3 * _sign
    assert_64x61(res)
    return (res)
end

# Calculates arcsin(x) for -1 <= x <= 1 (fixed point)
# arcsin(x) = arctan(x / sqrt(1 - x^2))
@view
func asin_fp {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (_sign) = sign(x)
    let (x1) = abs_value(x)

    if x1 == ONE:
        return (HALF_PI * _sign)
    end

    let (x1_2) = mul_fp(x1, x1)
    let (div) = sqrt_fp(ONE - x1_2)
    let (atan_arg) = div_fp(x1, div)
    let (res_u) = atan_fp(atan_arg)
    return (res_u * _sign)
end

# Calculates arccos(x) for -1 <= x <= 1 (fixed point)
# arccos(x) = arcsin(sqrt(1 - x^2)) - arctan identity has discontinuity at zero
@view
func acos_fp {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (_sign) = sign(x)
    let (x1) = abs_value(x)
    let (x1_2) = mul_fp(x1, x1)
    let (asin_arg) = sqrt_fp(ONE - x1_2)
    let (res_u) = asin_fp(asin_arg)

    if _sign == -1:
        local res = PI - res_u
        assert_64x61(res)
        return (res)
    else:
        return (res_u)
    end
end
