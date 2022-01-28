const chai = require('chai');
const almost = require('almost-equal');
const starknet = require('hardhat').starknet;
const BN = require('bignumber.js');

// Setup test suite
const expect = chai.expect;
const REL_TOL = 5e-7;
const ABS_TOL = 5e-7;

// Helpers
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

describe('Math', function () {
  this.timeout(600_000);
  let contract;

  before(async () => {
    const contractFactory = await starknet.getContractFactory('Math');
    contract = await contractFactory.deploy();
  });

  it('should return accurate results for multiplication', async () => {
    const count = 10;
    const xs = Array.from({ length: count }, () => Math.random() * 2 ** 32 - 2 ** 31);
    const ys = Array.from({ length: count }, () => Math.random() * 2 ** 32 - 2 ** 31);

    for (const [ i, x ] of xs.entries()) {
      const y = ys[i];
      const { res } = await contract.call('mul_fp', {
        x: to64x61(x),
        y: to64x61(y)
      });
      
      const exp = x * y;
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for division', async () => {
    const count = 10;
    const xs = Array.from({ length: count }, () => Math.random() * 2 ** 32 - 2 ** 31);
    const ys = Array.from({ length: count }, () => Math.random() * 2 ** 32 - 2 ** 31);

    for (const [ i, x ] of xs.entries()) {
      const y = ys[i];
      const { res } = await contract.call('div_fp', {
        x: to64x61(x),
        y: to64x61(y)
      });
      
      const exp = x / y;
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for powers', async () => {
    const xs = [ 4, 4, 4, 1024, 2 ** 16 - 1 , 4 , 64, -10, -10, -10 ];
    const ys = [ 0, 1, 2, 3, 3 , -2, -3, 1, 2, 3 ];

    for (const [ i, x ] of xs.entries()) {
      const y = ys[i];
      const { res } = await contract.call('pow_fp', {
        x: to64x61(x),
        y: toFelt(y)
      });

      const exp = x ** y;
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for sqrt', async () => {
    const xs = [ 1, 64, 2 ** 32, 7.21 ** 2 ];

    for (const x of xs) {
      const { res } = await contract.call('sqrt_fp', { x: to64x61(x) });
      const exp = Math.sqrt(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for binary exponent', async () => {
    const xs = [ 0, 1, 3, 5.5, -1, -5.5 ];

    for (const x of xs) {
      const { res } = await contract.call('exp2_fp', { x: to64x61(x) });
      const exp = 2 ** x;
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });
  
  it('should return accurate results for binary log', async () => {
    const xs = [ 0.5, 0.75, 1, 2, 5, 72.11 ];

    for (const x of xs) {
      const { res } = await contract.call('log2_fp', { x: to64x61(x) });
      const exp = Math.log2(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for natural log', async () => {
    const xs = [ 0.5, 1, Math.E, 5, 72.11 ];

    for (const x of xs) {
      const { res } = await contract.call('ln_fp', { x: to64x61(x) });
      const exp = Math.log(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for base10 log', async () => {
    const xs = [ 0.5, 1, 2, 10, 72.11 ];

    for (const x of xs) {
      const { res } = await contract.call('log10_fp', { x: to64x61(x) });
      const exp = Math.log10(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for sin of negative angles', async () => {
    const xs = [ -2.25, -2, -1.75, -1.5, -1.25, -1, -0.75, -0.5, -0.25 ];

    for (const x of xs) {
      const { res } = await contract.call('sin_fp', { x: toFelt(PI.times(x)) });
      const exp = Math.sin(x * Math.PI);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for sin of positive angles', async () => {
    const xs = [ 0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25 ];

    for (const x of xs) {
      const { res } = await contract.call('sin_fp', { x: toFelt(PI.times(x)) });
      const exp = Math.sin(x * Math.PI);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for cos of negative angles', async () => {
    const xs = [ -2.25, -2, -1.75, -1.5, -1.25, -1, -0.75, -0.5, -0.25 ];

    for (const x of xs) {
      const { res } = await contract.call('cos_fp', { x: toFelt(PI.times(x)) });
      const exp = Math.cos(x * Math.PI);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for cos of positive angles', async () => {
    const xs = [ 0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25 ];

    for (const x of xs) {
      const { res } = await contract.call('cos_fp', { x: toFelt(PI.times(x)) });
      const exp = Math.cos(x * Math.PI);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for tan of negative angles', async () => {
    const xs = [ -2.25, -2, -1.75, -1.25, -1, -0.75, -0.25 ];

    for (const x of xs) {
      const { res } = await contract.call('tan_fp', { x: toFelt(PI.times(x)) });
      const exp = Math.tan(x * Math.PI);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for tan of positive angles', async () => {
    const xs = [ 0, 0.25, 0.75, 1, 1.25, 1.75, 2, 2.25 ];

    for (const x of xs) {
      const { res } = await contract.call('tan_fp', { x: toFelt(PI.times(x)) });
      const exp = Math.tan(x * Math.PI);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for arctan', async () => {
    const xs = [ -1.5, -1 , -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1 ];

    for (const x of xs) {
      const { res } = await contract.call('atan_fp', { x: to64x61(x) });
      const exp = Math.atan(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for arcsin', async () => {
    const xs = [ -1 , -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1 ];

    for (const x of xs) {
      const { res } = await contract.call('asin_fp', { x: to64x61(x) });
      const exp = Math.asin(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for arccos', async () => {
    const xs = [ -1 , -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1 ];

    for (const x of xs) {
      const { res } = await contract.call('acos_fp', { x: to64x61(x) });
      const exp = Math.acos(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });
});