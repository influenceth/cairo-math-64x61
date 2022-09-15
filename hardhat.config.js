require('@shardlabs/starknet-hardhat-plugin');

module.exports = {
  starknet: {
    venv: 'active',
    starknetNetwork: 'integratedDevnet'
  },
  networks: {
    integratedDevnet: {
      url: "http://127.0.0.1:5050",
      dockerizedVersion: "0.3.0",
      args: [ "--lite-mode" ]
    },
  },
  solidity: '0.7.3',
};
