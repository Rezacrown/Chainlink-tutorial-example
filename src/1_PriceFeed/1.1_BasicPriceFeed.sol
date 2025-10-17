// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Import interface untuk Chainlink Price Feed
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * @title BasicPriceFeed
 * @dev Contract dasar untuk mendapatkan harga cryptocurrency dari Chainlink Price Feed
 * @notice Contoh implementasi Price Feed untuk ETH/USD di Sepolia testnet
 */
contract BasicPriceFeed {
    // Interface untuk berinteraksi dengan Chainlink Price Feed
    AggregatorV3Interface internal priceFeed;

    // Event untuk melacak ketika harga di-update
    event PriceUpdated(int256 price, uint256 timestamp);

    // Variabel untuk menyimpan harga terakhir
    int256 public lastPrice;
    uint256 public lastUpdate;

    /**
     * @dev Constructor untuk setup contract dengan address price feed
     * @param _priceFeedAddress Address dari Chainlink Price Feed contract
     * @notice Untuk Sepolia ETH/USD: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */
    constructor(address _priceFeedAddress) {
        // Inisialisasi interface dengan address yang diberikan
        priceFeed = AggregatorV3Interface(_priceFeedAddress);

        // Get harga saat contract di-deploy
        updatePrice();
    }

    /**
     * @dev Fungsi untuk mendapatkan harga terbaru dari Chainlink
     * @return price Harga terbaru dalam format dengan decimals
     * @notice Fungsi ini menggunakan view karena hanya membaca data
     */
    function getLatestPrice() public view returns (int256 price) {
        // Memanggil fungsi latestRoundData dari Chainlink aggregator
        // Fungsi ini mengembalikan tuple dengan beberapa values
        (
            ,
            /* uint80 roundID */ // ID round saat ini (tidak digunakan)
            int256 answer, // Harga dalam format dengan decimals
            /*uint256 startedAt*/ /*uint256 updatedAt*/ /*uint80 answeredInRound*/ // ID round ketika answer diberikan (tidak digunakan)
            ,
            ,

        ) = // Timestamp mulai round (tidak digunakan)
            // Timestamp update terakhir (tidak digunakan)
            priceFeed.latestRoundData();

        return answer;
    }

    /**
     * @dev Fungsi untuk mendapatkan harga dengan format yang benar (dibagi dengan decimals)
     * @return formattedPrice Harga dalam format yang mudah dibaca
     * @notice Contoh: Jika harga 200000000000 (dengan 8 decimals) akan return 2000.00000000
     */
    function getFormattedPrice() public view returns (int256 formattedPrice) {
        // Dapatkan harga mentah dari Chainlink
        int256 rawPrice = getLatestPrice();

        // Dapatkan jumlah decimals dari price feed
        uint8 decimals = priceFeed.decimals();

        // Format harga dengan membaginya dengan 10^decimals
        // Contoh: 200000000000 / 10^8 = 2000.00000000
        formattedPrice = rawPrice / int256(10 ** uint256(decimals));

        return formattedPrice;
    }

    /**
     * @dev Fungsi untuk update dan menyimpan harga terbaru
     * @notice Fungsi ini mengupdate state contract dan emit event
     */
    function updatePrice() public {
        // Dapatkan harga terbaru
        int256 currentPrice = getLatestPrice();

        // Update state variables
        lastPrice = currentPrice;
        lastUpdate = block.timestamp;

        // Emit event untuk notifikasi
        emit PriceUpdated(currentPrice, block.timestamp);
    }

    /**
     * @dev Fungsi untuk mendapatkan informasi decimals dari price feed
     * @return decimals Jumlah decimal places yang digunakan
     * @notice Biasanya 8 untuk USD pairs, 18 untuk ETH pairs
     */
    function getDecimals() public view returns (uint8 decimals) {
        return priceFeed.decimals();
    }

    /**
     * @dev Fungsi untuk mendapatkan deskripsi price feed
     * @return description String deskripsi dari price feed
     */
    function getDescription() public view returns (string memory description) {
        return priceFeed.description();
    }

    /**
     * @dev Fungsi untuk mendapatkan versi aggregator
     * @return version Versi dari aggregator contract
     */
    function getVersion() public view returns (uint256 version) {
        return priceFeed.version();
    }

    /**
     * @dev Fungsi untuk mengecek apakah data harga masih fresh
     * @return isFresh True jika data kurang dari 1 jam, false jika stale
     */
    function isPriceFresh() public view returns (bool isFresh) {
        // Jika belum pernah di-update, return false
        if (lastUpdate == 0) return false;

        // Data dianggap fresh jika kurang dari 1 jam
        return (block.timestamp - lastUpdate) < 1 hours;
    }

    /**
     * @dev Fungsi untuk mendapatkan semua informasi price feed sekaligus
     * @return currentPrice Harga terbaru
     * @return formattedPrice Harga yang sudah diformat
     * @return freshness Status kesegaran data
     * @return decimals Jumlah decimals
     */
    function getPriceInfo()
        public
        view
        returns (
            int256 currentPrice,
            int256 formattedPrice,
            bool freshness,
            uint8 decimals
        )
    {
        currentPrice = getLatestPrice();
        formattedPrice = getFormattedPrice();
        freshness = isPriceFresh();
        decimals = getDecimals();
    }
}
