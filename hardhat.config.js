/** @type import('hardhat/config').HardhatUserConfig */

require('@nomiclabs/hardhat-ethers')
require('@nomicfoundation/hardhat-chai-matchers')
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.17",
};

const ALCHEMY_API_KEY = "_KmVPA96VqCvRfwe1Aqtvsdf6w-";
const GOERLI_PRIVATE_KEY = "ae8df608900ddaafde1fdb2343a404a4996bfds21fcea2e533ee8259637123";
module.exports = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY]
    }
  }
};
