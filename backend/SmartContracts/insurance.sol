Insurance
// SimpleStorage.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//RUN ON REMIX

contract InsuranceContract {
    uint256 allowance=2000;

    // Function to validate & calculate new allowance
    function calculateAllowance(uint256 bill) public view returns (uint256) {
        return allowance - bill > 0 ? allowance - bill : allowance;
    }
}
