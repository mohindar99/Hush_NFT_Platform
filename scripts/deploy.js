const hre = require("hardhat");

async function main_nft() {
  const NFT_sale = await hre.ethers.getContractFactory("NFT_sale");
  const nft_sale = await NFT_sale.deploy();

  await nft_sale.deployed();

  console.log("NFT sale got deployed ", nft_sale.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main_nft().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

