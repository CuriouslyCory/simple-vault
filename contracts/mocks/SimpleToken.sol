// SPDX-License-Identifier: MIT
/*
Author: CuriouslyCory
Website: https://curiouslycory.com
Twitter: @CuriouslyCory
*/

pragma solidity ^0.8.11;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleToken is ERC20 {
    constructor(string memory _name, string memory _symbol, uint128 quantity) ERC20(_name, _symbol) {
        _mint(msg.sender, quantity * 10 ** uint(decimals()));
    }
}