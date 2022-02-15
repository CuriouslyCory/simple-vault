import { expect } from "chai";
import { ethers } from "hardhat";

describe("SimpleVault", function () {
  it("Should return the new greeting once it's changed", async function () {
    const SimpleVault = await ethers.getContractFactory("SimpleVault");
    const simpleVault = await SimpleVault.deploy("Hello, world!");
    await simpleVault.deployed();

    expect(await simpleVault.greet()).to.equal("Hello, world!");

    const setGreetingTx = await simpleVault.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await simpleVault.greet()).to.equal("Hola, mundo!");
  });
});
