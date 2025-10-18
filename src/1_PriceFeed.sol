// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract PriceFeedExample {
    // interfaces
    AggregatorV3Interface private aggPrice;

    // ETH/USD address in base sepolia
    address public constant ETHUSD = 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1;

    constructor() {
        // set aggregator price for get real price ETH/USD
        aggPrice = AggregatorV3Interface(ETHUSD);
    }

    function getEthPrice() public view returns (int256 ethPrice) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 price,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = aggPrice.latestRoundData();

        ethPrice = price / int256(10 ** uint256(aggPrice.decimals()));
    }
}
