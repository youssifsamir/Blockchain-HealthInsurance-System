// Graduation Project defense 1 - prototype
// TYPE         > Ethereum Smart contract
// FUNCTION     > Gold Price in USD
// ENVIRONMENT  > Solidity
// NETWORK      > Ethereum Sepolia test network
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

// RUN ON REMIX
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DataConsumerV3 {
    AggregatorV3Interface internal dataFeed;
    string priceReturned;

    function substring(
        string memory str,
        uint startIndex,
        uint endIndex
    ) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        require(startIndex <= endIndex, "Invalid substring range");
        require(endIndex < strBytes.length, "End index out of bounds");
        bytes memory result = new bytes(endIndex - startIndex + 1);
        for (uint i = startIndex; i <= endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function getLatestData(address feedAddress) public returns (string memory) {
        dataFeed = AggregatorV3Interface(feedAddress);
        (
            ,
            /* uint80 roundID */ int answer /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = dataFeed.latestRoundData();
        string memory answerString = Strings.toString(answer);
        // string memory priceSubstring = substring(answerString, 0, 3);
        // return string(abi.encodePacked(priceSubstring));
        return answerString;
    }
}
