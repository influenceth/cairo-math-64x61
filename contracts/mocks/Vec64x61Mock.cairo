%lang starknet

from Vec64x61 import (
    Vec64x61_add,
    Vec64x61_sub,
    Vec64x61_mul,
    Vec64x61_dot,
    Vec64x61_cross,
    Vec64x61_norm
)

@view
func Vec64x61_add_test {range_check_ptr} (a: (felt, felt, felt), b: (felt, felt, felt)) -> (res: (felt, felt, felt)):
    let (res) = Vec64x61_add(a, b)
    return (res)
end

@view
func Vec64x61_sub_test {range_check_ptr} (a: (felt, felt, felt), b: (felt, felt, felt)) -> (res: (felt, felt, felt)):
    let (res) = Vec64x61_sub(a, b)
    return (res)
end

@view
func Vec64x61_mul_test {range_check_ptr} (a: (felt, felt, felt), b: felt) -> (res: (felt, felt, felt)):
    let (res) = Vec64x61_mul(a, b)
    return (res)
end

@view
func Vec64x61_dot_test {range_check_ptr} (a: (felt, felt, felt), b: (felt, felt, felt)) -> (res: felt):
    let (res) = Vec64x61_dot(a, b)
    return (res)
end

@view
func Vec64x61_cross_test {range_check_ptr} (a: (felt, felt, felt), b: (felt, felt, felt)) -> (res: (felt, felt, felt)):
    let (res) = Vec64x61_cross(a, b)
    return (res)
end

@view
func Vec64x61_norm_test {range_check_ptr} (a: (felt, felt, felt)) -> (res: felt):
    let (res) = Vec64x61_norm(a)
    return (res)
end