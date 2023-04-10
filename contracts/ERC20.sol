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