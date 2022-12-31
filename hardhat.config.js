/** @type import('hardhat/config').HardhatUserConfig */
//require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan")
const dotenv = require("dotenv");
dotenv.config();

module.exports = {
  solidity: "0.8.17",

  networks: {
    georli: {
      url: `${process.env.RPC_URL}`,
      accounts:[`${process.env.PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY,
  }
};
