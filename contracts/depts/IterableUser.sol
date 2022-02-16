// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

library IterableUser {
    struct UserStruct {
        address[] keys;
        mapping(address => uint256) indexOf;
        mapping(address => uint256) value;
        mapping(address => uint) blockNum;
        mapping(address => uint) exists; // use a uint instead of bool to save gas
    }
    
    // get
    // returns uint256 balance, uint blockNum
    function get(UserStruct storage map, address key) internal view returns(uint256, uint) {
        return (map.value[key], map.blockNum[key]);
    }

    // getBalance
    // returns uint256 balance of address
    function getBalance(UserStruct storage map, address key) internal view returns(uint256) {
        return map.value[key];
    }

    // getBlockNum
    // returns uint last deposit block number for address
    function getBlockNum(UserStruct storage map, address key) internal view returns(uint) {
        return map.blockNum[key];
    }

    // length
    // returns uint current number of addresses tracked in mapping
    function length(UserStruct storage map) internal view returns (uint) {
        return map.keys.length;
    }

    function findAddrAtIndex(UserStruct storage map, uint index) internal view returns (address) {
        return map.keys[index];
    }
    
    // set
    // params: address: key - address is primarilly how we do lookups
    //         uint256: value - balance of tokens in vault for address
    //         uint:    blockNum - block number of last deposit
    function set(UserStruct storage map, address key, uint256 value, uint blockNum) internal {
        if(map.exists[key] == 1) {
            map.value[key] = value;
            map.blockNum[key] = blockNum;
        }else{
            map.exists[key] = 1; 
            map.value[key] = value; 
            map.blockNum[key] = blockNum;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }
}
