%lang starknet

from hyp_64x61 import sinh_fp, cosh_fp, tanh_fp, asinh_fp, acosh_fp, atanh_fp

@view
func sinh_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = sinh_fp(x)
    return (res)
end

@view
func cosh_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = cosh_fp(x)
    return (res)
end

@view
func tanh_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = tanh_fp(x)
    return (res)
end

@view
func asinh_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = asinh_fp(x)
    return (res)
end

@view
func acosh_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = acosh_fp(x)
    return (res)
end

@view
func atanh_fp_test {range_check_ptr} (x: felt) -> (res: felt):
    let (res) = atanh_fp(x)
    return (res)
end
