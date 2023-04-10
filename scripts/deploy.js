const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with :", deployer.address);

  const ERC20 = await ethers.getContractFactory("ERC20");
  const token = await ERC20.deploy();

  console.log("ERC20 address:", token.address);

  const BankContract = await ethers.getContractFactory("BankContract");
  const bank = await BankContract.deploy();

  console.log("BankContract address:", bank.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });