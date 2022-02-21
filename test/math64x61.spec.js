const chai = require('chai');
const almost = require('almost-equal');
const starknet = require('hardhat').starknet;
const { toFelt, to64x61, from64x61 } = require('./helpers');

// Setup test suite
const expect = chai.expect;
const REL_TOL = 5e-7;
const ABS_TOL = 5e-7;

describe('64.61 fixed point math', function () {
  this.timeout(600_000);
  let contract;

  before(async () => {
    const contractFactory = await starknet.getContractFactory('Math64x61Mock');
    contract = await contractFactory.deploy();
  });

  it('should return accurate results for floor', async () => {
    const count = 10;
    const xs = Array.from({ length: count }, () => Math.random() * 2 ** 32 - 2 ** 31);

    for (const x of xs) {
      const { res } = await contract.call('Math64x61_floor_test', { x: to64x61(x) });
      const exp = Math.floor(x);
      expect(from64x61(res)).to.eq(exp);
    }
  });

  it('should return accurate results for ceiling', async () => {
    const count = 10;
    const xs = Array.from({ length: count }, () => Math.random() * 2 ** 32 - 2 ** 31);

    for (const x of xs) {
      const { res } = await contract.call('Math64x61_ceil_test', { x: to64x61(x) });
      const exp = Math.ceil(x);
      expect(from64x61(res)).to.eq(exp);
    }
  });

  it('should return accurate results for min', async () => {
    const count = 10;
    const xs = Array.from({ length: count }, () => Math.random() * 2 ** 32 - 2 ** 31);
    const ys = Array.from({ length: count }, () => Math.random() * 2 ** 32 - 2 ** 31);

    for (const [ i, x ] of xs.entries()) {
      const y = ys[i];
      const { res } = await contract.call('Math64x61_min_test', { x: to64x61(x), y: to64x61(y) });
      const exp = Math.min(x, y);
      expect(from64x61(res)).to.eq(exp);
    }
  });

  it('should return accurate results for max', async () => {
    const count = 10;
    const xs = Array.from({ length: count }, () => Math.random() * 2 ** 32 - 2 ** 31);
    const ys = Array.from({ length: count }, () => Math.random() * 2 ** 32 - 2 ** 31);

    for (const [ i, x ] of xs.entries()) {
      const y = ys[i];
      const { res } = await contract.call('Math64x61_max_test', { x: to64x61(x), y: to64x61(y) });
      const exp = Math.max(x, y);
      expect(from64x61(res)).to.eq(exp);
    }
  });

  it('should return accurate results for multiplication', async () => {
    const count = 10;
    const xs = Array.from({ length: count }, () => Math.random() * 2 ** 32 - 2 ** 31);
    const ys = Array.from({ length: count }, () => Math.random() * 2 ** 32 - 2 ** 31);

    for (const [ i, x ] of xs.entries()) {
      const y = ys[i];
      const { res } = await contract.call('Math64x61_mul_test', {
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
      const { res } = await contract.call('Math64x61_div_test', {
        x: to64x61(x),
        y: to64x61(y)
      });
      
      const exp = x / y;
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for powers', async () => {
    const xs = [ 4, 4, 4 , 1024, 2 ** 16 - 1 , 4 , 64, -10, -10, -10, 0.5, 0.25, 0.125 ];
    const ys = [ 0, 1, 2 , 3, 3 , -2, -3, 1, 2, 3, 0.5, 1, 1.5 ];

    for (const [ i, x ] of xs.entries()) {
      const y = ys[i];
      const { res } = await contract.call('Math64x61_pow_test', {
        x: to64x61(x),
        y: to64x61(y)
      });

      const exp = x ** y;
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });
  
  it('should return accurate results for sqrt', async () => {
    const xs = [ 1, 64, 2 ** 32, 7.21 ** 2 ];

    for (const x of xs) {
      const { res } = await contract.call('Math64x61_sqrt_test', { x: to64x61(x) });
      const exp = Math.sqrt(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for binary exponent', async () => {
    const xs = [ 0, 1, 3, 5.5, -1, -5.5 ];

    for (const x of xs) {
      const { res } = await contract.call('Math64x61_exp2_test', { x: to64x61(x) });
      const exp = 2 ** x;
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });
  
  it('should return accurate results for binary log', async () => {
    const xs = [ 0.5, 0.75, 1, 2, 5, 72.11 ];

    for (const x of xs) {
      const { res } = await contract.call('Math64x61_log2_test', { x: to64x61(x) });
      const exp = Math.log2(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for natural log', async () => {
    const xs = [ 0.5, 1, Math.E, 5, 72.11 ];

    for (const x of xs) {
      const { res } = await contract.call('Math64x61_ln_test', { x: to64x61(x) });
      const exp = Math.log(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for base10 log', async () => {
    const xs = [ 0.5, 1, 2, 10, 72.11 ];

    for (const x of xs) {
      const { res } = await contract.call('Math64x61_log10_test', { x: to64x61(x) });
      const exp = Math.log10(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });
});
