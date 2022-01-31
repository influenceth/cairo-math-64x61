%lang starknet

from Trig64x61 import (
    Trig64x61_sin,
    Trig64x61_cos,
    Trig64x61_tan,
    Trig64x61_atan,
    Trig64x61_asin,
    Trig64x61_acos
)

@view
func  Trig64x61_sin_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) =  Trig64x61_sin(x)
    return (res)
end

@view
func Trig64x61_cos_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Trig64x61_cos(x)
    return (res)
end

@view
func Trig64x61_tan_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Trig64x61_tan(x)
    return (res)
end

@view
func Trig64x61_atan_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Trig64x61_atan(x)
    return (res)
end

@view
func Trig64x61_asin_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Trig64x61_asin(x)
    return (res)
end

@view
func  Trig64x61_acos_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) =  Trig64x61_acos(x)
    return (res)
end