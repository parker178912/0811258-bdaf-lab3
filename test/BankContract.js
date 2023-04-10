const { ethers } = require("hardhat");
const { expect } = require("chai");
describe("BankContract", function () {
  it("Check for deposit and withdraw tokens.", async function () {
    // Deploy ERC20 and Bank contract
    const ERC20 = await ethers.getContractFactory("ERC20");
    const token = await ERC20.deploy();
    const BankContract = await ethers.getContractFactory("BankContract");
    const bank = await BankContract.deploy();

    // Approve the BankContract to get tokens from ERC20
    const amount = 100;
    await token.approve(bank.address, amount);

    // Deposit tokens into the BankContract
    await bank.deposit(token.address, amount);

    // Check the balance of the user
    const user_balance = await bank.getBalance(token.address);
    expect(user_balance).to.equal(amount);

    // Withdraw tokens
    await bank.withdraw(token.address, amount);

    // Check the balance of the user again
    const user_balance_end = await bank.getBalance(token.address);
    expect(user_balance_end).to.equal(0);
  });
});