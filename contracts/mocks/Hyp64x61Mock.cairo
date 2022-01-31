%lang starknet

from Hyp64x61 import (
    Hyp64x61_sinh,
    Hyp64x61_cosh,
    Hyp64x61_tanh,
    Hyp64x61_asinh,
    Hyp64x61_acosh,
    Hyp64x61_atanh
)

@view
func Hyp64x61_sinh_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Hyp64x61_sinh(x)
    return (res)
end

@view
func Hyp64x61_cosh_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Hyp64x61_cosh(x)
    return (res)
end

@view
func Hyp64x61_tanh_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Hyp64x61_tanh(x)
    return (res)
end

@view
func Hyp64x61_asinh_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Hyp64x61_asinh(x)
    return (res)
end

@view
func Hyp64x61_acosh_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Hyp64x61_acosh(x)
    return (res)
end

@view
func Hyp64x61_atanh_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = Hyp64x61_atanh(x)
    return (res)
end
