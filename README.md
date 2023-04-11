# 0811258-bdaf-lab3
## Setting environment

```bash
mkdir lab3
cd lab3
npm install --save-dev hardhat
npx hardhat
(choose "Create an empty hardhat.config.js")
mkdir contracts test scripts
code
npm install --save-dev @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-ethers ethers
npm install @openzeppelin/contracts
```

- **`ethers`** 是一個 Ethereum JavaScript 客戶端庫，它提供了簡單易用的 API 來與 Ethereum 網路進行互動，包括帳戶管理、智能合約部署、交易發送等功能。
- **`@nomiclabs/hardhat-waffle`** 是 Hardhat 中用來測試智能合約的套件，它提供了一些有用的測試輔助函數，例如可以方便地模擬以太坊網路上的交易、事件等。
- **`ethereum-waffle`** 是 Waffle 的一個簡化版本，它提供了更加簡潔易用的 API 來寫智能合約測試。
- **`@nomiclabs/hardhat-ethers`**是 Hardhat Ethers.js 整合插件，它讓 Hardhat 能夠更好地與 Ethers.js 客戶端庫進行整合，包括方便地部署和調用智能合約等功能。
- **`chai`**是一個 JavaScript 斷言庫，它提供了許多測試斷言和測試輔助函數，可以讓你更輕鬆地編寫測試用例。

## Contracts folder

add following code in path `contracts/BankContract.sol` : 

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract BankContract{
    using SafeMath for uint256;
    mapping(address => mapping(address => uint256)) private balances;
    
    function deposit(address token_address, uint256 amount) public{
        require(amount > 0, "Deposit amount must greater than 0");
        require(token_address != address(0), "Can't send token to 0x00..");
        require(IERC20(token_address).transferFrom(msg.sender,address(this), amount), "Transfer failed");
        balances[msg.sender][token_address] += amount;
    }
    
    function withdraw(address token_address, uint256 amount) public{
        require(amount > 0, "Withdraw amount must greater than 0");
        require(balances[msg.sender][token_address] >= amount, "You don't have enough amount to withdraw");
        balances[msg.sender][token_address] -= amount;
        require(IERC20(token_address).transfer(msg.sender, amount), "Transfer failed");
    }
    
    function getBalance(address token_address) public view returns(uint256 balance){
        return balances[msg.sender][token_address];
    }
}
```

add following code in path `contracts/ERC20.sol` :

```solidity
 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
contract ERC20 is IERC20{
    using SafeMath for uint256;
    
    uint256 private _totalSupply;
    mapping(address => uint256)  _balances;
    mapping(address => mapping(address => uint256)) _approve;
    constructor(){
        _balances[msg.sender]=10000;
        _totalSupply=10000;
    }

    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }
    
    function balanceOf(address your_address) external view returns (uint256 balance){
        return _balances[your_address];
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool success){
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount);
        emit Transfer(from, to, amount);
        return true;
    }   

    function transfer(address to, uint256 amount) external returns (bool success){
        return _transfer(msg.sender, to, amount);
    }
    
    function allowance(address allow_address, address approve_address) external view returns (uint256 remain_amount){
        return _approve[allow_address][approve_address];
    }
  
    function approve(address approve_address, uint256 amount) external returns (bool success){
        _approve[msg.sender][approve_address] = amount;
        emit Approval(msg.sender, approve_address, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool success){
        _approve[from][msg.sender] = _approve[from][msg.sender].sub(amount);
        return _transfer(from, to, amount);
    }
}
```

## Script folder

add following code in path `scripts/deploy.js` :

```jsx
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
```

## Test folder

add following code in path  `test/BankContract.js` : 

```jsx
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
```

## Compile & Test

```bash
npx hardhat compile
npm i solidity-coverage
npm install hardhat-gas-reporter --save-dev
```

- **`solidity-coverage`**可以幫助開發者衡量他們 Solidity 智能合約代碼的測試覆蓋率，並且生成代碼覆蓋率報告，方便開發者評估他們的測試用例的有效性和 Solidity 代碼的質量。
- **`hardhat-gas-reporter`**可以幫助開發者評估他們 Solidity 智能合約的燃氣消耗情況。它會在每次運行 Solidity 測試時，收集並報告每個測試用例所消耗的燃氣量。開發者可以通過這些信息優化他們的 Solidity 代碼，以降低燃氣消耗量。

```bash
npx hardhat test
```

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/704eaab7-4d64-4f4a-8e2e-dbf8d992aadd/Untitled.png)

## Deploy

add `.env` file : 

```bash
API_URL = "https://eth-goerli.g.alchemy.com/v2/YOUR_API_URL "
PRIVATE_KEY = "YOUR_PRIVATE_KEY"
ETHERSCAN_API_KEY = "YOUR_ETHERSCAN_API_KEY"
```

fill in `hardhat.config.js` :

```jsx
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require('hardhat-deploy');
require("hardhat-deploy-ethers");
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan")
const API_URL = process.env.API_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
// Your API key for Etherscan
// Obtain one at https://etherscan.io/
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

module.exports = {
  defaultNetwork: "goerli",
  networks: {
    hardhat: {},
    goerli: {
       url: API_URL,
       accounts: [`0x${PRIVATE_KEY}`]
    }
 },
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  }
};
```

deploy : 

```bash
npm install dotenv --save
npm install --save-dev hardhat-deploy
npm install --save-dev hardhat-deploy-ethers
npm install --save-dev @nomiclabs/hardhat-etherscan
npx hardhat run scripts/deploy.js --network goerli
```

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/276ef33b-600a-496c-9236-2ace721c3e3e/Untitled.png)

Check the contracts on [goerli etherscan](https://goerli.etherscan.io/), and you can see that the contract aren’t verified yet.

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/e55a9209-497b-4786-a7db-dc994ce69a00/Untitled.png)

## Verify

```bash
npx hardhat verify --network goerli <contract-address>
npx hardhat verify --network goerli 0x9aEc1a013F80C0ceD97de7E1CBeC5B3ba5E332DE
npx hardhat verify --network goerli 0x26b805937D5fE10fd3174669CaF1c45B1FcBB0cC
```

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/a0d491f4-ad12-4cfe-b605-0c4a2f8d64b0/Untitled.png)

You can see that the contract is verified !!
