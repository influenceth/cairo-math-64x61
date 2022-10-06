%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le

from contracts.cairo_math_64x61.math64x61 import Math64x61

@external
func __setup__{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    %{ max_examples(1000) %}
    return ();
}

@external
func setup_correctness() {
    %{
        given(
            x = strategy.integers(-2 ** 64, 2 ** 64),
            y = strategy.integers(-2 ** 64, 2 ** 64),
        )
    %}
    return ();
}

@external
func test_exp{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}(x: felt) {
    alloc_locals;

    // 0.1% tolerance
    let tolerance = 1;
    local left_bound: felt;
    local right_bound: felt;
    %{
        import math

        want = math.exp(ids.x);

        ids.left_bound = math.floor((want * (1000 - ids.tolerance)) / 1000);
        ids.right_bound = math.ceil((want * (1000 + ids.tolerance)) / 1000);
    %}

    let x_fp = Math64x61.fromFelt(x);
    let got_fp = Math64x61.exp(x_fp);
    let got = Math64x61.toFelt(got_fp);

    let left = is_le(left_bound, got);
    let right = is_le(got, right_bound);

    assert left + right = 2;

    return ();
}
