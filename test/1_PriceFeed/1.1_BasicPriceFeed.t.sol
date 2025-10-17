// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

// Import contract yang akan di-test
import {BasicPriceFeed} from "../../src/1_PriceFeed/1.1_BasicPriceFeed.sol";

/**
 * @title BasicPriceFeedTest
 * @dev Test suite untuk BasicPriceFeed contract
 * @notice Test semua fungsi dan edge cases untuk Price Feed implementation
 */
contract BasicPriceFeedTest is Test {
    // Instance contract yang akan di-test
    BasicPriceFeed public priceFeed;

    // Address ETH/USD Price Feed di Sepolia testnet
    address constant ETH_USD_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    // Setup function yang dijalankan sebelum setiap test
    function setUp() public {
        // load .env setup fork sepolia testnet
        // string memory rpcUrl = vm.envString("ETH_SEPOLIA_RPC_URL");

        // // create fork
        // uint256 forkId = vm.createFork(rpcUrl);
        // // select fork chainId
        // vm.selectFork(forkId);

        // Deploy contract dengan ETH/USD price feed address
        priceFeed = new BasicPriceFeed(ETH_USD_FEED);
    }

    /**
     * @dev Test constructor setup
     * @notice Pastikan contract ter-deploy dengan benar
     */
    function testConstructor() public view {
        // Pastikan contract ter-deploy
        assertTrue(address(priceFeed) != address(0));

        // Pastikan harga terakhir sudah di-set (tidak nol)
        assertTrue(priceFeed.lastPrice() != 0);

        // Pastikan timestamp update terakhir sudah di-set
        assertTrue(priceFeed.lastUpdate() != 0);
    }

    /**
     * @dev Test mendapatkan harga terbaru
     * @notice Pastikan fungsi getLatestPrice mengembalikan nilai yang valid
     */
    function testGetLatestPrice() public view {
        // Panggil fungsi getLatestPrice
        int256 price = priceFeed.getLatestPrice();

        // Harga harus lebih besar dari 0 (ETH tidak mungkin bernilai 0)
        assertGt(price, 0, "Price should be greater than 0");

        // Log harga untuk debugging
        console.log("ETH/USD Price:", uint256(price));
    }

    /**
     * @dev Test mendapatkan harga dengan format yang benar
     * @notice Pastikan formatted price sesuai dengan decimals
     */
    function testGetFormattedPrice() public view {
        // Dapatkan formatted price
        int256 formattedPrice = priceFeed.getFormattedPrice();

        // Formatted price harus lebih besar dari 0
        assertGt(formattedPrice, 0, "Formatted price should be greater than 0");

        // Log formatted price
        console.log("Formatted ETH/USD Price:", uint256(formattedPrice));
    }

    /**
     * @dev Test fungsi updatePrice
     * @notice Pastikan updatePrice mengupdate state dan emit event
     */
    function testUpdatePrice() public {
        // Simpan state sebelum update
        int256 oldPrice = priceFeed.lastPrice();
        uint256 oldTimestamp = priceFeed.lastUpdate();

        // Tunggu 1 detik untuk memastikan timestamp berbeda
        vm.warp(block.timestamp + 1);

        // Expect event PriceUpdated akan di-emit
        vm.expectEmit(true, true, true, true);
        emit BasicPriceFeed.PriceUpdated(
            priceFeed.getLatestPrice(),
            block.timestamp
        );

        // Panggil updatePrice
        priceFeed.updatePrice();

        // Pastikan state ter-update
        assertTrue(
            priceFeed.lastPrice() != oldPrice ||
                priceFeed.lastUpdate() != oldTimestamp
        );
    }

    /**
     * @dev Test mendapatkan informasi decimals
     * @notice Pastikan decimals sesuai dengan expected value (biasanya 8 untuk USD)
     */
    function testGetDecimals() public view {
        uint8 decimals = priceFeed.getDecimals();

        // Untuk ETH/USD pair, decimals biasanya 8
        assertEq(decimals, 8, "ETH/USD decimals should be 8");

        console.log("Decimals:", decimals);
    }

    /**
     * @dev Test mendapatkan deskripsi price feed
     * @notice Pastikan description string tidak kosong
     */
    function testGetDescription() public view {
        string memory description = priceFeed.getDescription();

        // Deskripsi harus tidak kosong
        assertGt(
            bytes(description).length,
            0,
            "Description should not be empty"
        );

        console.log("Description:", description);
    }

    /**
     * @dev Test mendapatkan versi aggregator
     * @notice Pastikan version number valid
     */
    function testGetVersion() public view {
        uint256 version = priceFeed.getVersion();

        // Version harus lebih dari 0
        assertGt(version, 0, "Version should be greater than 0");

        console.log("Version:", version);
    }

    /**
     * @dev Test freshness check
     * @notice Pastikan fungsi isPriceFresh bekerja dengan benar
     */
    function testIsPriceFresh() public view {
        bool isFresh = priceFeed.isPriceFresh();

        // Karena contract baru di-deploy, data harus fresh
        assertTrue(isFresh, "Price data should be fresh after deployment");
    }

    /**
     * @dev Test mendapatkan semua informasi sekaligus
     * @notice Pastikan getPriceInfo mengembalikan semua values dengan benar
     */
    function testGetPriceInfo() public view {
        (
            int256 currentPrice,
            int256 formattedPrice,
            bool freshness,
            uint8 decimals
        ) = priceFeed.getPriceInfo();

        // Semua values harus valid
        assertGt(currentPrice, 0, "Current price should be valid");
        assertGt(formattedPrice, 0, "Formatted price should be valid");
        assertTrue(freshness, "Price should be fresh");
        assertEq(decimals, 8, "Decimals should be 8");

        console.log("Current Price:", uint256(currentPrice));
        console.log("Formatted Price:", uint256(formattedPrice));
        console.log("Is Fresh:", freshness);
        console.log("Decimals:", decimals);
    }

    /**
     * @dev Test dengan address price feed yang invalid
     * @notice Pastikan contract handle invalid address dengan graceful
     */
    function testInvalidPriceFeedAddress() public {
        vm.expectRevert();
        
        // Deploy contract dengan address yang tidak valid
        BasicPriceFeed invalidPriceFeed = new BasicPriceFeed(address(0x123));
        

        // Fungsi yang memanggil price feed harus handle error dengan baik
        // (Dalam real scenario, contract mungkin revert)
        // Test ini untuk demonstrasi error handling
    }

    /**
     * @dev Test edge case dengan price feed yang down
     * @notice Simulasikan scenario dimana price feed tidak merespons
     */
    function testPriceFeedDown() public {
        // Simulasikan price feed yang mengembalikan harga 0
        // (Dalam implementasi real, ini akan memerlukan mock)
        // Test ini sebagai placeholder untuk future mocking tests
    }


    /**
     * @dev Test multiple calls untuk verifikasi konsistensi
     * @notice Pastikan multiple calls mengembalikan hasil yang konsisten
     */
    function testMultipleCallsConsistency() public view {
        // Panggil getLatestPrice beberapa kali
        int256 price1 = priceFeed.getLatestPrice();
        int256 price2 = priceFeed.getLatestPrice();
        int256 price3 = priceFeed.getLatestPrice();


        // Semua calls harus mengembalikan nilai yang sama (dalam block yang sama)
        assertEq(price1, price2, "Price should be consistent between calls");
        assertEq(price2, price3, "Price should be consistent between calls");
    }
}
