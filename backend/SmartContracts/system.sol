
Medicale
// SimpleStorage.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//RUN ON REMIX

contract SystemContract {

    // Function to decrement medicane storage value
    function decrementStorageValue(uint256 storageValue, uint256 quantity) public pure returns (uint256) {
        return storageValue - quantity;
    }
}

