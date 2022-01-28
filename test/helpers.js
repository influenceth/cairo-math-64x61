const BN = require('bignumber.js');

const SCALE = BN(2).pow(61);
const PRIME = BN(3618502788666131213697322783095070105623107215331596699973092056135872020481n);
const PRIME_HALF = PRIME.idiv(2);
const PI = BN(7244019458077122842n);

// Converts to a felt representation
const toFelt = (num) => {
  let res = BN(num);
  return BigInt(res.integerValue().toString(10));
}

// Converts to Cairo 64.61 representation
const to64x61 = (num) => {
  let res = BN(num).times(SCALE);
  if (res.gt(BN(2).pow(125)) || res.lte(BN(2).pow(125).negated())) throw new Error('Number is out of valid range')
  return toFelt(res);
};

// Negative values are returned by Starknet so no need to wrap
const from64x61 = (num) => {
  let res = BN(num);
  res = res.gt(PRIME_HALF) ? res.minus(PRIME) : res;
  return res.div(SCALE).toNumber();
}

module.exports = {
  SCALE,
  PRIME,
  PRIME_HALF,
  PI,
  toFelt,
  to64x61,
  from64x61
};