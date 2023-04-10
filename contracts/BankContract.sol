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