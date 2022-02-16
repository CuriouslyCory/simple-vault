// SPDX-License-Identifier: MIT
/*
Author: CuriouslyCory
Website: https://curiouslycory.com
Twitter: @CuriouslyCory
*/

pragma solidity ^0.8.11;

import "hardhat/console.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {UserInfo} from "./depts/UserInfo.sol";
import {TopHolder} from "./depts/TopHolder.sol";

pragma solidity ^0.8.11;

import "hardhat/console.sol";

contract SimpleVault is Ownable, ReentrancyGuard{
    using SafeMath for uint256;

    IERC20 public immutable simpleToken;
    mapping (address => UserInfo) private _userPool;
    TopHolder[2] private topHolder;

    // constructor: initializes the contract
    // params: _simpleToken: the address of the token we want to store in this vault
    constructor(address _simpleToken) {
        require(_simpleToken != address(0), "Address is required");
        simpleToken = IERC20(_simpleToken);
    }

    // balanceOf: returns the balance of an account
    // params: account: address of the wallet we want to return the balance for
    function balanceOf(address _account) external view returns (uint256) {
        require(_account != address(0), "Address is required");
        return _userPool[_account]._balance;
    }

    // deposit: transfer funds into the contract and track balance
    // params: _amount: how much of the ERC20 token to deposit
    function deposit(uint256 _amount) public {
        simpleToken.transferFrom(msg.sender, address(this), _amount);
        _userPool[msg.sender]._balance.add(_amount);
        updateTopHolder(msg.sender, _userPool[msg.sender]._balance);
    }

    // withdraw: transfer funds out of the contract and track balance
    // params: how much of the ERC20 token to withdraw from the vault
    function withdraw(uint256 _amount) public nonReentrant{
        require(this.balanceOf(msg.sender) >= _amount, "Not enough available tokens");
        simpleToken.transferFrom(address(this), msg.sender, _amount);
        _userPool[msg.sender]._balance.sub(_amount);
        updateTopHolder(msg.sender, _userPool[msg.sender]._balance);
    }

    // updateTopHolder: check the top 2 slots to 
    // params what address just updated their balance
    // there's a major flaw here where 1 or 2 withdraws enough to be 3 or less, but we don't have any to back-fill the slot.
    // was trying to avoid itteration to save on gas, but ultimately I'll need to come up with a new method that isn't a fuel guzzler
    function updateTopHolder(address _updateFor, uint256 _newAmount) private {
        // 2 becomes 1 && 1 becomes 2
        // 1 becomes 2 && 2 becomes 1
        // replace 1 && 1 becomes 2
        // replace 2
        if(topHolder[1]._address == _updateFor && _newAmount > topHolder[0]._balance){
            // #2 has advanced to #1
            TopHolder memory tmpHolder = topHolder[0];
            topHolder[0]._address = _updateFor;
            topHolder[0]._balance = _newAmount;
            topHolder[1] = tmpHolder;
        }else if(_newAmount > topHolder[0]._balance){
            // if new #1, move 1 to 2 and add new 1;
            topHolder[1] = topHolder[0];
            topHolder[0]._balance = _newAmount;
            topHolder[0]._address = _updateFor;
        }else if(_newAmount < topHolder[0]._balance && _newAmount > topHolder[1]._balance){
            // if balance is greater than #2 but less than #1 replace #2 value
            topHolder[1]._balance = _newAmount;
            topHolder[1]._address = _updateFor;
        }
    }

    // getTopDepositors: returns 2 users with most of funds in the pool
    function getTopDepositors() public view returns (address[2]  memory) {
        return [topHolder[0]._address, topHolder[1]._address];
    }
}
