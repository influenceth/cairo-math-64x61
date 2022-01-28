%lang starknet

from trig_64x61 import sin_fp, cos_fp, tan_fp, atan_fp, asin_fp, acos_fp

@view
func sin_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = sin_fp(x)
    return (res)
end

@view
func cos_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = cos_fp(x)
    return (res)
end

@view
func tan_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = tan_fp(x)
    return (res)
end

@view
func atan_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = atan_fp(x)
    return (res)
end

@view
func asin_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = asin_fp(x)
    return (res)
end

@view
func acos_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = acos_fp(x)
    return (res)
end