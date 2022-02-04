const chai = require('chai');
const almost = require('almost-equal');
const starknet = require('hardhat').starknet;
const math = require('mathjs');
const { PI, toFelt, to64x61, from64x61 } = require('./helpers');

// Setup test suite
const expect = chai.expect;
const REL_TOL = 5e-7;
const ABS_TOL = 5e-7;

const randVec3 = (min = -1, max = 1) => {
  const x = Math.random() * (max - min) + min;
  const y = Math.random() * (max - min) + min;
  const z = Math.random() * (max - min) + min;
  return [ x, y, z ];
};

describe('64.61 vector math functions', function () {
  this.timeout(600_000);
  let contract;

  before(async () => {
    const contractFactory = await starknet.getContractFactory('Vec64x61Mock');
    contract = await contractFactory.deploy();
  });

  it('should return accurate results for vector addition', async () => {
    const count = 10;
    const as = Array.from({ length: count }, () => randVec3(-(2 ** 31), 2 ** 31))
    const bs = Array.from({ length: count }, () => randVec3(-(2 ** 31), 2 ** 31))

    for (const [ i, a ] of as.entries()) {
      const { res } = await contract.call(
        'Vec64x61_add_test',
        { a: a.map((v) => to64x61(v)), b: bs[i].map((v) => to64x61(v)) }
      );

      for (const [ j, v ] of a.entries()) {
        const exp = v + bs[i][j];
        expect(almost(from64x61(res[j]), exp, ABS_TOL, REL_TOL), `${from64x61(res[j])} != ${exp}`).to.be.true;
      }
    }
  });

  it('should return accurate results for vector subtraction', async () => {
    const count = 10;
    const as = Array.from({ length: count }, () => randVec3(-(2 ** 31), 2 ** 31))
    const bs = Array.from({ length: count }, () => randVec3(-(2 ** 31), 2 ** 31))

    for (const [ i, a ] of as.entries()) {
      const { res } = await contract.call(
        'Vec64x61_sub_test',
        { a: a.map((v) => to64x61(v)), b: bs[i].map((v) => to64x61(v)) }
      );

      for (const [ j, v ] of a.entries()) {
        const exp = v - bs[i][j];
        expect(almost(from64x61(res[j]), exp, ABS_TOL, REL_TOL), `${from64x61(res[j])} != ${exp}`).to.be.true;
      }
    }
  });

  it('should return accurate results for vector scalar multiplication', async () => {
    const count = 10;
    const as = Array.from({ length: count }, () => randVec3(-(2 ** 32), 2 ** 32))
    const bs = Array.from({ length: count }, () => Math.random() * 2 ** 32 - 2 ** 31);

    for (const [ i, a ] of as.entries()) {
      const { res } = await contract.call(
        'Vec64x61_mul_test',
        { a: a.map((v) => to64x61(v)), b: to64x61(bs[i]) }
      );

      for (const [ j, v ] of a.entries()) {
        const exp = v * bs[i];
        expect(almost(from64x61(res[j]), exp, ABS_TOL, REL_TOL), `${from64x61(res[j])} != ${exp}`).to.be.true;
      }
    }
  });

  it('should return accurate results for vector dot product', async () => {
    const count = 10;
    const as = Array.from({ length: count }, () => randVec3(-(2 ** 32), 2 ** 32))
    const bs = Array.from({ length: count }, () => randVec3(-(2 ** 31), 2 ** 31))

    for (const [ i, a ] of as.entries()) {
      const { res } = await contract.call(
        'Vec64x61_dot_test',
        { a: a.map((v) => to64x61(v)), b: bs[i].map((v) => to64x61(v)) }
      );

      const exp = math.dot(a, bs[i]);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });

  it('should return accurate results for vector cross product', async () => {
    const count = 10;
    const as = Array.from({ length: count }, () => randVec3(-(2 ** 32), 2 ** 32))
    const bs = Array.from({ length: count }, () => randVec3(-(2 ** 31), 2 ** 31))

    for (const [ i, a ] of as.entries()) {
      const { res } = await contract.call(
        'Vec64x61_cross_test',
        { a: a.map((v) => to64x61(v)), b: bs[i].map((v) => to64x61(v)) }
      );

      const exp = math.cross(a, bs[i]);

      for (const [ j, v ] of exp.entries()) {
        expect(almost(from64x61(res[j]), v, ABS_TOL, REL_TOL), `${from64x61(res[j])} != ${exp}`).to.be.true;
      }
    }
  });

  it('should return accurate results for vector norm / magnitude / length', async () => {
    const count = 10;
    const as = Array.from({ length: count }, () => randVec3(-(2 ** 32), 2 ** 32))

    for (let a of as) {
      const { res } = await contract.call('Vec64x61_norm_test', { a: a.map((v) => to64x61(v)) });
      const exp = Math.hypot(...a);
      expect(almost(from64x61(res), exp, ABS_TOL, REL_TOL), `${from64x61(res)} != ${exp}`).to.be.true;
    }
  });
});