%lang starknet

from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.math import sign, abs_value, unsigned_div_rem, assert_not_zero
from Math64x61 import (
    Math64x61_FRACT_PART,
    Math64x61_ONE,
    Math64x61_mul,
    Math64x61_div,
    Math64x61_sqrt,
    Math64x61_assert64x61
)

const Trig64x61_PI = 7244019458077122842
const Trig64x61_HALF_PI = 3622009729038561421

# Helper function to calculate Taylor series for sin
func Trig64x61__sin_loop {range_check_ptr} (x: felt, i: felt, acc: felt) -> (res: felt):
    alloc_locals

    if i == -1:
        return (acc)
    end

    let (num) = Math64x61_mul(x, x)
    tempvar div = (2 * i + 2) * (2 * i + 3) * Math64x61_FRACT_PART
    let (t) = Math64x61_div(num, div)
    let (t_acc) = Math64x61_mul(t, acc)
    let (next) = Trig64x61__sin_loop(x, i - 1, Math64x61_ONE - t_acc)
    return (next)
end

# Calculates sin(x) with x in radians (fixed point)
func Trig64x61_sin {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (_sign1) = sign(x) # extract sign
    let (abs1) = abs_value(x)
    let (_, x1) = unsigned_div_rem(abs1, 2 * Trig64x61_PI)
    let (rem, x2) = unsigned_div_rem(x1, Trig64x61_PI)
    local _sign2 = 1 - (2 * rem)
    let (acc) = Trig64x61__sin_loop(x2, 6, Math64x61_ONE)
    let (res2) = Math64x61_mul(x2, acc)
    local res = res2 * _sign1 * _sign2
    Math64x61_assert64x61(res)
    return (res)
end

# Calculates cos(x) with x in radians (fixed point)
func Trig64x61_cos {range_check_ptr} (x: felt) -> (res: felt):
    tempvar shifted = Trig64x61_HALF_PI - x
    let (res) = Trig64x61_sin(shifted)
    return (res)
end

# Calculates tan(x) with x in radians (fixed point)
func Trig64x61_tan {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (sinx) = Trig64x61_sin(x)
    let (cosx) = Trig64x61_cos(x)
    assert_not_zero(cosx)
    let (res) = Math64x61_div(sinx, cosx)
    return (res)
end

# Calculates arctan(x) (fixed point)
# See https://stackoverflow.com/a/50894477 for range adjustments
func Trig64x61_atan {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    const sqrt3_3 = 1331279082078542925 # sqrt(3) / 3
    const pi_6 = 1207336576346187140 # pi / 6
    const p_7 = 1614090106449585766 # 0.7
    
    # Calculate on positive values and re-assign later
    let (_sign) = sign(x)
    let (abs_x) = abs_value(x)

    # Invert value when x > 1
    let (_invert) = is_le(Math64x61_ONE, abs_x)
    local x1a_num = abs_x * (1 - _invert) + _invert * Math64x61_ONE
    tempvar x1a_div = abs_x * _invert + Math64x61_ONE - Math64x61_ONE * _invert
    let (x1a) = Math64x61_div(x1a_num, x1a_div)

    # Account for lack of precision in polynomaial when x > 0.7
    let (_shift) = is_le(p_7, x1a)
    local b = sqrt3_3 * _shift + Math64x61_ONE - _shift * Math64x61_ONE
    local x1b_num = x1a - b
    let (x1b_div_2) = Math64x61_mul(x1a, b)
    tempvar x1b_div = Math64x61_ONE + x1b_div_2
    let (x1b) = Math64x61_div(x1b_num, x1b_div)
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
    
    let (r8) = Math64x61_mul(a8, x1)
    let (r7) = Math64x61_mul(r8 + a7, x1)
    let (r6) = Math64x61_mul(r7 + a6, x1)
    let (r5) = Math64x61_mul(r6 + a5, x1)
    let (r4) = Math64x61_mul(r5 + a4, x1)
    let (r3) = Math64x61_mul(r4 + a3, x1)
    let (r2) = Math64x61_mul(r3 + a2, x1)
    tempvar z1 = r2 + a1

    # Adjust for sign change, inversion, and shift
    tempvar z2 = z1 + (pi_6 * _shift)
    tempvar z3 = (z2 - (Trig64x61_HALF_PI * _invert)) * (1 - _invert * 2)
    local res = z3 * _sign
    Math64x61_assert64x61(res)
    return (res)
end

# Calculates arcsin(x) for -1 <= x <= 1 (fixed point)
# arcsin(x) = arctan(x / sqrt(1 - x^2))
func Trig64x61_asin {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (_sign) = sign(x)
    let (x1) = abs_value(x)

    if x1 == Math64x61_ONE:
        return (Trig64x61_HALF_PI * _sign)
    end

    let (x1_2) = Math64x61_mul(x1, x1)
    let (div) = Math64x61_sqrt(Math64x61_ONE - x1_2)
    let (atan_arg) = Math64x61_div(x1, div)
    let (res_u) = Trig64x61_atan(atan_arg)
    return (res_u * _sign)
end

# Calculates arccos(x) for -1 <= x <= 1 (fixed point)
# arccos(x) = arcsin(sqrt(1 - x^2)) - arctan identity has discontinuity at zero
func Trig64x61_acos {range_check_ptr} (x: felt) -> (res: felt):
    alloc_locals

    let (_sign) = sign(x)
    let (x1) = abs_value(x)
    let (x1_2) = Math64x61_mul(x1, x1)
    let (asin_arg) = Math64x61_sqrt(Math64x61_ONE - x1_2)
    let (res_u) = Trig64x61_asin(asin_arg)

    if _sign == -1:
        local res = Trig64x61_PI - res_u
        Math64x61_assert64x61(res)
        return (res)
    else:
        return (res_u)
    end
end