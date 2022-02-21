require('@shardlabs/starknet-hardhat-plugin');

module.exports = {
  starknet: {
    venv: 'active',
    starknetNetwork: 'starknetLocal'
  },
  networks: {
    starknetLocal: {
      url: 'http://localhost:5000'
    }
  },
  solidity: '0.7.3',
};
