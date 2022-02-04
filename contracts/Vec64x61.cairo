%lang starknet

from Math64x61 import (
    Math64x61_assert64x61,
    Math64x61_add,
    Math64x61_sub,
    Math64x61_mul,
    Math64x61_sqrt
)

# Calculate the vector sum of two 3D vectors
func Vec64x61_add {range_check_ptr} (a: (felt, felt, felt), b: (felt, felt, felt)) -> (res: (felt, felt, felt)):
    let (x) = Math64x61_add(a[0], b[0])
    let (y) = Math64x61_add(a[1], b[1])
    let (z) = Math64x61_add(a[2], b[2])
    return ((x, y, z))
end

# Calculates vector subtraction for two 3D vectors
func Vec64x61_sub {range_check_ptr} (a: (felt, felt, felt), b: (felt, felt, felt)) -> (res: (felt, felt, felt)):
    let (x) = Math64x61_sub(a[0], b[0])
    let (y) = Math64x61_sub(a[1], b[1])
    let (z) = Math64x61_sub(a[2], b[2])
    return ((x, y, z))
end

# Calculates the scalar product of a 3D vector and a fixed point value
func Vec64x61_mul {range_check_ptr} (a: (felt, felt, felt), b: felt) -> (res: (felt, felt, felt)):
    let (x) = Math64x61_mul(a[0], b)
    let (y) = Math64x61_mul(a[1], b)
    let (z) = Math64x61_mul(a[2], b)
    return ((x, y, z))
end

# Calculates the dot product of two 3D vectors
func Vec64x61_dot {range_check_ptr} (a: (felt, felt, felt), b: (felt, felt, felt)) -> (res: felt):
    let (x) = Math64x61_mul(a[0], b[0])
    let (y) = Math64x61_mul(a[1], b[1])
    let (z) = Math64x61_mul(a[2], b[2])
    let (res) = Math64x61_add(x + y, z)
    return (res)
end

# Calculates the cross product of two 3D vectors
func Vec64x61_cross {range_check_ptr} (a: (felt, felt, felt), b: (felt, felt, felt)) -> (res: (felt, felt, felt)):
    let (x1) = Math64x61_mul(a[1], b[2])
    let (x2) = Math64x61_mul(a[2], b[1])
    let (x) = Math64x61_sub(x1, x2)
    let (y1) = Math64x61_mul(a[2], b[0])
    let (y2) = Math64x61_mul(a[0], b[2])
    let (y) = Math64x61_sub(y1, y2)
    let (z1) = Math64x61_mul(a[0], b[1])
    let (z2) = Math64x61_mul(a[1], b[0])
    let (z) = Math64x61_sub(z1, z2)
    return ((x, y, z))
end

# Calculates the length / norm (L2) of a 3D vector
func Vec64x61_norm {range_check_ptr} (a: (felt, felt, felt)) -> (res: felt):
    let (x2) = Math64x61_mul(a[0], a[0])
    let (y2) = Math64x61_mul(a[1], a[1])
    let (z2) = Math64x61_mul(a[2], a[2])
    let (res) = Math64x61_sqrt(x2 + y2 + z2)
    return (res)
end