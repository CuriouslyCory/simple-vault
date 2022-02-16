import { expect } from "chai";
import { ethers } from "hardhat";

describe("SimpleVault", function () {
  it("Test ", async function () {
    const [owner] = await ethers.getSigners();

    const initialTokenBalance = BigInt(100000 * Math.pow(10, 18));

    const SimpleToken = await ethers.getContractFactory("SimpleToken");
    const simpleToken = await SimpleToken.deploy("SimpleToken", "SIM", initialTokenBalance);
    await simpleToken.deployed();

    const SimpleVault = await ethers.getContractFactory("SimpleVault");
    const simpleVault = await SimpleVault.deploy(simpleToken.address);
    await simpleVault.deployed();
    console.log(await simpleVault.getTopDepositors());
    expect(await simpleVault.getTopDepositors()).to.equal(['0x0000000000000000000000000000000000000000','0x0000000000000000000000000000000000000000']);
  });
});
