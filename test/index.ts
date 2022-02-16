import { expect } from "chai";
import { ethers } from "hardhat";

describe("SimpleVault", function () {
  it("Test ", async function () {
    // get wallets to use in test cases
    const [owner, secondary] = await ethers.getSigners();

    // balance to mint on mock ERC20 token
    const initialTokenBalance = BigInt(100000 * Math.pow(10, 18));

    // deploy "simpletoken" a basic ERC20. Owner should recieve "initialTokenBalance" to wallet
    const SimpleToken = await ethers.getContractFactory("SimpleToken");
    const simpleToken = await SimpleToken.deploy("SimpleToken", "SIM", initialTokenBalance);
    await simpleToken.deployed();

    // todo: test to validate balance in wallet
    //let ownerBalance = BigInt(await simpleToken.balanceOf(owner.address));
    //expect(ownerBalance).to.eq(initialTokenBalance);

    // send funds to secondary wallet
    await simpleToken.approve(owner.address, BigInt(1000 * Math.pow(10, 18)));
    await simpleToken.transferFrom(owner.address, secondary.address, BigInt(1000 * Math.pow(10, 18)));
    // todo: validate funds in secondary wallet

    // deploy SimpleVault that should recieve and hold SIM balances
    const SimpleVault = await ethers.getContractFactory("SimpleVault");
    const simpleVault = await SimpleVault.deploy(simpleToken.address);
    await simpleVault.deployed();

    // verify vault initialized correctly
    console.log(await simpleVault.getTopDepositors());
    
    // top vault addresses should be empty
    let topDepositors = await simpleVault.getTopDepositors();
    expect(topDepositors[0]).to.equal(['0x0000000000000000000000000000000000000000','0x0000000000000000000000000000000000000000']);

    // todo: deposit 100 tokens from owner
    await simpleToken.increaseAllowance(simpleVault.address, BigInt(100 * Math.pow(10, 18)));
    await simpleVault.deposit(BigInt(100 * Math.pow(10, 18)));

    // todo: verify owner is #1 depositor
    console.log(await simpleVault.getTopDepositors());
    //expect(await impleVault.getTopDepositors()).to.equal(["0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266","0x0000000000000000000000000000000000000000"]);
    
    // todo: deposit 50 from account number 2
    await simpleToken.connect(secondary).increaseAllowance(simpleVault.address, BigInt(100 * Math.pow(10, 18)));
    await simpleVault.connect(secondary).deposit(BigInt(50 * Math.pow(10, 18)));

    console.log(await simpleVault.getTopDepositors());
    
    // todo: withdraw 75 token from account 1 (should leave balance of 25)
    await simpleToken.increaseAllowance(owner.address, BigInt(75 * Math.pow(10, 18)));
    await simpleVault.withdraw(BigInt(75 * Math.pow(10, 18)));
    console.log(await simpleVault.balanceOf(owner.address));
    console.log(await simpleVault.getTopDepositors());

    // todo:
  });
});
