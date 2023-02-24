require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@nomicfoundation/hardhat-toolbox");
let PRIVATE_KEY="a475d672e029ad8d4f63ed3f50c87e9cdf00f29caf26ea01d9d7e0a03b040b72";
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {

  networks: {
    matic: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/X1H7etINPr6jELA9HL7ofrvMHGnyhBcU`,
      accounts: [PRIVATE_KEY]
    }
  },
  solidity: {

    compilers:[
      {
        version: '0.6.0',
      },
      {
        version: '0.8.9',
      }
    ]
  },
  etherscan: {
    apiKey: {
      polygonMumbai: 'KDUE344NY1N55XVGURHMWTA13IK1PK2SVG'
    }
  }
};
