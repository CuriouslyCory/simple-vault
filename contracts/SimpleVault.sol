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
import {TopHolder} from "./depts/TopHolder.sol";
import {IterableUser} from "./depts/IterableUser.sol";

contract SimpleVault is Ownable, ReentrancyGuard{
    using SafeMath for uint256;
    using IterableUser for IterableUser.UserStruct;

    IERC20 public immutable simpleToken;
    TopHolder[2] private topHolders;
    IterableUser.UserStruct private vaultMap;

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
        return vaultMap.getBalance(_account);
    }

    // deposit: transfer funds into the contract and track balance
    // params: _amount: how much of the ERC20 token to deposit
    function deposit(uint256 _amount) public {
        simpleToken.transferFrom(msg.sender, address(this), _amount);
        vaultMap.set(msg.sender, this.balanceOf(msg.sender).add(_amount), block.number);
        updateTopHolder();
    }

    // withdraw: transfer funds out of the contract and track balance
    // params: _amount: how much of the ERC20 token to withdraw from the vault
    function withdraw(uint256 _amount) public nonReentrant{
        require(this.balanceOf(msg.sender) >= _amount, "Not enough available tokens");
        simpleToken.transfer(msg.sender, _amount);
        vaultMap.set(msg.sender, this.balanceOf(msg.sender).sub(_amount), block.number);
        updateTopHolder();
    }

    // updateTopHolder: check the top 2 slots to 
    // params _updateFor: what address just updated their balance
    //        _newAmount: balance of address after recent change
    // this would likely become a gas hog at high user counts, further optimization warranted
    // possible solution would be to maintiain a seperate object for the top x accounts and 
    // only run itterations over a smaller map
    function updateTopHolder() private {
        uint256[2] memory topVals;
        address[2] memory topAddrs;
        uint256 curBalance;
        address curAddress;
        uint256 i;

        for(i = 0; i <= vaultMap.length() - 1; i++){
            curAddress = vaultMap.findAddrAtIndex(i);
            curBalance = vaultMap.getBalance(curAddress);
            if(curBalance < topVals[1]){
                continue;
            }
            if(curBalance > topVals[0]){
                //copy spot 1 to spot 2
                topVals[1] = topVals[0];
                topAddrs[1] = topAddrs[0];
                // add new spot 1
                topVals[0] = curBalance;
                topAddrs[0] = curAddress;
            }else if(curBalance > topVals[1]){
                topVals[1] = curBalance;
                topAddrs[1] = curAddress;
            }
        }

        topHolders[0]._balance = topVals[0];
        topHolders[0]._address = topAddrs[0];
        topHolders[1]._balance = topVals[1];
        topHolders[1]._address = topAddrs[1];
    }

    // getTopDepositors: returns 2 users with most of funds in the pool
    function getTopDepositors() public view returns (address[2]  memory) {
        return [topHolders[0]._address, topHolders[1]._address];
    }

    
}
