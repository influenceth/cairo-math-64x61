const chai = require('chai');
const almost = require('almost-equal');
const starknet = require('hardhat').starknet;
const { PI, toFelt, to64x61, from64x61 } = require('./helpers');

// Setup test suite
const expect = chai.expect;
const REL_TOL = 5e-7;
const ABS_TOL = 5e-7;

describe('64.61 fixed point hyperbolic functions', function () {
  this.timeout(600_000);
  let contract;

  before(async () => {
    const contractFactory = await starknet.getContractFactory('Hyp64x61Mock');
    contract = await contractFactory.deploy();
  });

  it('should return accurate results for sinh', async () => {
    const xs = [ -10 , -2, -1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1, 2, 10 ];

    for (const x of xs) {
      const { res } = await contract.call('Hyp64x61_sinh_test', { x: to64x61(x) });
      const exp = Math.sinh(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for cosh', async () => {
    const xs = [ -10 , -2, -1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1, 2, 10 ];

    for (const x of xs) {
      const { res } = await contract.call('Hyp64x61_cosh_test', { x: to64x61(x) });
      const exp = Math.cosh(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for tanh', async () => {
    const xs = [ -10 , -2, -1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1, 2, 10 ];

    for (const x of xs) {
      const { res } = await contract.call('Hyp64x61_tanh_test', { x: to64x61(x) });
      const exp = Math.tanh(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for asinh', async () => {
    const xs = [ -10 , -2, -1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1, 2, 10 ];

    for (const x of xs) {
      const { res } = await contract.call('Hyp64x61_asinh_test', { x: to64x61(x) });
      const exp = Math.asinh(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for acosh', async () => {
    const xs = [ 1, 1.5, 2, 4, 10 ];

    for (const x of xs) {
      const { res } = await contract.call('Hyp64x61_acosh_test', { x: to64x61(x) });
      const exp = Math.acosh(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for atanh', async () => {
    const xs = [ -0.95, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 0.95 ];

    for (const x of xs) {
      const { res } = await contract.call('Hyp64x61_atanh_test', { x: to64x61(x) });
      const exp = Math.atanh(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });
});