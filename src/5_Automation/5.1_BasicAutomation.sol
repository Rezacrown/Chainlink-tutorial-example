// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Import interfaces untuk Chainlink Automation
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";

/**
 * @title BasicAutomation
 * @dev Contract dasar untuk Chainlink Automation
 * @notice Contoh implementasi Automation untuk scheduled task execution
 */
contract BasicAutomation is AutomationCompatibleInterface {
    // Event untuk melacak upkeep execution
    event UpkeepPerformed(uint256 timestamp, uint256 counter);
    event UpkeepSkipped(uint256 timestamp, string reason);

    // State variables untuk automation logic
    uint256 public lastTimeStamp;
    uint256 public interval;
    uint256 public counter;
    bool public paused;

    /**
     * @dev Constructor untuk setup automation parameters
     * @param _interval Interval waktu antara setiap upkeep (dalam detik)
     */
    constructor(uint256 _interval) {
        interval = _interval;
        lastTimeStamp = block.timestamp;
        counter = 0;
        paused = false;
    }

    /**
     * @dev Fungsi untuk check apakah upkeep diperlukan
     * @param checkData Data tambahan untuk check (tidak digunakan dalam contoh ini)
     * @return upkeepNeeded True jika upkeep diperlukan, false jika tidak
     * @return performData Data yang akan digunakan dalam performUpkeep
     */
    function checkUpkeep(
        bytes calldata checkData
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        // Check jika contract sedang paused
        if (paused) {
            return (false, "");
        }

        // Check jika sudah waktunya untuk melakukan upkeep
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;

        // Untuk contoh ini, kita tidak butuh performData tambahan
        performData = checkData;

        return (upkeepNeeded, performData);
    }

    /**
     * @dev Fungsi yang dijalankan oleh Chainlink Automation ketika upkeep diperlukan
     * @param performData Data yang dikembalikan dari checkUpkeep
     */
    function performUpkeep(bytes calldata performData) external override {
        // Validasi bahwa upkeep memang diperlukan
        // Ini penting untuk mencegah execution yang tidak perlu
        require(
            (block.timestamp - lastTimeStamp) > interval,
            "Upkeep not needed"
        );

        // Validasi bahwa contract tidak paused
        require(!paused, "Contract is paused");

        // Update timestamp terakhir
        lastTimeStamp = block.timestamp;

        // Increment counter
        counter++;

        // Logika bisnis tambahan bisa ditambahkan di sini
        // Contoh: distribute rewards, update state, dll.

        // Emit event untuk tracking
        emit UpkeepPerformed(block.timestamp, counter);

        // PerformData bisa digunakan untuk logic tambahan
        // Contoh: jika performData tidak kosong, process data tersebut
        if (performData.length > 0) {
            // Process performData jika ada
            // Contoh: (string memory message) = abi.decode(performData, (string));
        }
    }

    /**
     * @dev Fungsi untuk mendapatkan informasi automation
     * @return currentCounter Nilai counter saat ini
     * @return nextUpkeepTime Perkiraan waktu upkeep berikutnya
     * @return isPaused Status paused contract
     */
    function getAutomationInfo()
        external
        view
        returns (uint256 currentCounter, uint256 nextUpkeepTime, bool isPaused)
    {
        currentCounter = counter;
        nextUpkeepTime = lastTimeStamp + interval;
        isPaused = paused;
    }

    /**
     * @dev Fungsi untuk mengupdate interval automation
     * @param _interval Interval baru (dalam detik)
     * @notice Hanya owner yang bisa memanggil fungsi ini
     */
    function updateInterval(uint256 _interval) external {
        // Dalam implementasi real, tambahkan modifier onlyOwner
        // require(msg.sender == owner, "Only owner can update interval");

        require(_interval > 0, "Interval must be greater than 0");
        interval = _interval;
    }

    /**
     * @dev Fungsi untuk pause/unpause automation
     * @param _paused True untuk pause, false untuk unpause
     * @notice Hanya owner yang bisa memanggil fungsi ini
     */
    function setPaused(bool _paused) external {
        // Dalam implementasi real, tambahkan modifier onlyOwner
        // require(msg.sender == owner, "Only owner can pause/unpause");

        paused = _paused;
    }

    /**
     * @dev Fungsi untuk reset counter (untuk testing purposes)
     * @notice Hanya owner yang bisa memanggil fungsi ini
     */
    function resetCounter() external {
        // Dalam implementasi real, tambahkan modifier onlyOwner
        // require(msg.sender == owner, "Only owner can reset counter");

        counter = 0;
        lastTimeStamp = block.timestamp;
    }

    /**
     * @dev Fungsi untuk mengecek apakah upkeep akan diperlukan dalam waktu tertentu
     * @param _secondsInFuture Jumlah detik ke depan untuk dicek
     * @return willBeNeeded True jika upkeep akan diperlukan dalam waktu yang ditentukan
     */
    function willUpkeepBeNeeded(
        uint256 _secondsInFuture
    ) external view returns (bool willBeNeeded) {
        if (paused) {
            return false;
        }

        uint256 futureTime = block.timestamp + _secondsInFuture;
        willBeNeeded = (futureTime - lastTimeStamp) > interval;

        return willBeNeeded;
    }

    /**
     * @dev Fungsi untuk mendapatkan time remaining sampai upkeep berikutnya
     * @return timeRemaining Waktu tersisa sampai upkeep (dalam detik), 0 jika sudah lewat
     */
    function getTimeUntilNextUpkeep()
        external
        view
        returns (uint256 timeRemaining)
    {
        if (paused) {
            return type(uint256).max; // Return max value jika paused
        }

        uint256 nextUpkeep = lastTimeStamp + interval;

        if (block.timestamp >= nextUpkeep) {
            return 0; // Sudah lewat waktu upkeep
        } else {
            return nextUpkeep - block.timestamp;
        }
    }

    /**
     * @dev Fungsi untuk manual trigger upkeep (untuk testing/emergency)
     * @notice Bisa digunakan untuk testing tanpa menunggu Automation
     */
    function manualUpkeep() external {
        // Validasi bahwa upkeep memang diperlukan
        require(
            (block.timestamp - lastTimeStamp) > interval,
            "Upkeep not needed"
        );

        // Validasi bahwa contract tidak paused
        require(!paused, "Contract is paused");

        // Update timestamp terakhir
        lastTimeStamp = block.timestamp;

        // Increment counter
        counter++;

        // Emit event untuk tracking
        emit UpkeepPerformed(block.timestamp, counter);
    }
}
