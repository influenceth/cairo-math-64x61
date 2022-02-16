require('@shardlabs/starknet-hardhat-plugin');

module.exports = {
  starknet: {
    venv: 'active'
  },
  networks: {
    starknetLocal: {
      url: 'http://localhost:5000'
    }
  },
  mocha: {
    // Used for deployment in Mocha tests
    // Defaults to "alpha" (for Alpha testnet), which is preconfigured even if you don't see it under `networks:`
    starknetNetwork: 'starknetLocal'
  },
  solidity: '0.7.3',
};
