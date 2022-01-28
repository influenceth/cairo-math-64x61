const chai = require('chai');
const almost = require('almost-equal');
const starknet = require('hardhat').starknet;
const { PI, toFelt, to64x61, from64x61 } = require('./helpers');

// Setup test suite
const expect = chai.expect;
const REL_TOL = 5e-7;
const ABS_TOL = 5e-7;

describe('64.61 fixed point trigonometric functions', function () {
  this.timeout(600_000);
  let contract;

  before(async () => {
    const contractFactory = await starknet.getContractFactory('trig_64x61_mock');
    contract = await contractFactory.deploy();
  });

  it('should return accurate results for sin of negative angles', async () => {
    const xs = [ -2.25, -2, -1.75, -1.5, -1.25, -1, -0.75, -0.5, -0.25 ];

    for (const x of xs) {
      const { res } = await contract.call('sin_fp_test', { x: toFelt(PI.times(x)) });
      const exp = Math.sin(x * Math.PI);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for sin of positive angles', async () => {
    const xs = [ 0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25 ];

    for (const x of xs) {
      const { res } = await contract.call('sin_fp_test', { x: toFelt(PI.times(x)) });
      const exp = Math.sin(x * Math.PI);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for cos of negative angles', async () => {
    const xs = [ -2.25, -2, -1.75, -1.5, -1.25, -1, -0.75, -0.5, -0.25 ];

    for (const x of xs) {
      const { res } = await contract.call('cos_fp_test', { x: toFelt(PI.times(x)) });
      const exp = Math.cos(x * Math.PI);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for cos of positive angles', async () => {
    const xs = [ 0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25 ];

    for (const x of xs) {
      const { res } = await contract.call('cos_fp_test', { x: toFelt(PI.times(x)) });
      const exp = Math.cos(x * Math.PI);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for tan of negative angles', async () => {
    const xs = [ -2.25, -2, -1.75, -1.25, -1, -0.75, -0.25 ];

    for (const x of xs) {
      const { res } = await contract.call('tan_fp_test', { x: toFelt(PI.times(x)) });
      const exp = Math.tan(x * Math.PI);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for tan of positive angles', async () => {
    const xs = [ 0, 0.25, 0.75, 1, 1.25, 1.75, 2, 2.25 ];

    for (const x of xs) {
      const { res } = await contract.call('tan_fp_test', { x: toFelt(PI.times(x)) });
      const exp = Math.tan(x * Math.PI);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for arctan', async () => {
    const xs = [ -1.5, -1 , -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1 ];

    for (const x of xs) {
      const { res } = await contract.call('atan_fp_test', { x: to64x61(x) });
      const exp = Math.atan(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for arcsin', async () => {
    const xs = [ -1 , -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1 ];

    for (const x of xs) {
      const { res } = await contract.call('asin_fp_test', { x: to64x61(x) });
      const exp = Math.asin(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for arccos', async () => {
    const xs = [ -1 , -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1 ];

    for (const x of xs) {
      const { res } = await contract.call('acos_fp_test', { x: to64x61(x) });
      const exp = Math.acos(x);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });
});