%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_le

from contracts.cairo_math_64x61.math64x61 import Math64x61

@external
func __setup__{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    %{ max_examples(1000) %}
    return ();
}

@external
func setup_ln_exp() {
    %{
        given(
            x = strategy.integers(1, 2 ** 64),
        )
    %}
    return ();
}

@external
func test_ln_exp{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}(x: felt) {
    alloc_locals;

    // 0.1% tolerance
    let tolerance = 1;
    local left_bound_exp: felt;
    local right_bound_exp: felt;
    local left_bound_ln: felt;
    local right_bound_ln: felt;
    %{
        import math

        want_ln = math.log(ids.x)
        want_exp = math.exp(want_ln);

        ids.left_bound_ln = math.floor((want_ln * (1000 - ids.tolerance)) / 1000);
        ids.right_bound_ln = math.ceil((want_ln * (1000 + ids.tolerance)) / 1000);

        ids.left_bound_exp = math.floor((want_exp * (1000 - ids.tolerance)) / 1000);
        ids.right_bound_exp = math.ceil((want_exp * (1000 + ids.tolerance)) / 1000);
    %}

    let x_fp = Math64x61.fromFelt(x);
    let ln_fp = Math64x61.ln(x_fp);
    let ln = Math64x61.toFelt(ln_fp);

    assert_le(left_bound_ln, ln);
    assert_le(ln, right_bound_ln);

    let exp_fp = Math64x61.exp(ln_fp);
    let exp = Math64x61.toFelt(exp_fp);

    assert_le(left_bound_exp, exp);
    assert_le(exp, right_bound_exp);

    return ();
}
