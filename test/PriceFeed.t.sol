// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {PriceFeedExample} from "../src/1_PriceFeed.sol";

contract PriceFeedExampleTest is Test {
    PriceFeedExample public priceFeedContract;

    function setUp() public {
        priceFeedContract = new PriceFeedExample();
    }

    function test_getEthPrice() public {
        vm.roll(36864848);

        int256 price = priceFeedContract.getEthPrice();

        console.log(price);

        assertGt(price, 0);
    }
}
