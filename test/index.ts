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

    expect(await simpleVault.getTopDepositors()).to.be(0);

    //const setGreetingTx = await simpleVault.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    //await setGreetingTx.wait();

    //expect(await simpleVault.greet()).to.equal("Hola, mundo!");
  });
});
