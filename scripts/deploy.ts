// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // We get the contract to deploy
  const tokenAddress = '0x130966628846BFd36ff31a822705796e8cb8C18D'; //avax mim
  const SimpleVault = await ethers.getContractFactory("SimpleVault");
  const simpleVault = await SimpleVault.deploy(tokenAddress);

  await simpleVault.deployed();

  console.log("Vault deployed to:", simpleVault.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
