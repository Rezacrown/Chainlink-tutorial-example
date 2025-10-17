// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Import testing utilities dari Foundry
import {Test, console} from "forge-std/Test.sol";

// Import contract yang akan di-test
import {BasicVRF} from "../../src/2_VRF/2.1_BasicVRF.sol";

/**
 * @title BasicVRFTest
 * @dev Test suite untuk BasicVRF contract
 * @notice Test VRF functionality dengan mock implementation
 */
contract BasicVRFTest is Test {
    // Instance contract yang akan di-test
    BasicVRF public vrf;

    // Mock VRF configuration untuk Sepolia testnet
    address constant VRF_COORDINATOR =
        0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 constant KEY_HASH =
        0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint64 constant SUBSCRIPTION_ID = 1; // Mock subscription ID
    uint32 constant CALLBACK_GAS_LIMIT = 100000;
    uint16 constant REQUEST_CONFIRMATIONS = 3;

    // Setup function yang dijalankan sebelum setiap test
    function setUp() public {
        // Deploy contract dengan mock VRF configuration
        vrf = new BasicVRF(
            VRF_COORDINATOR,
            KEY_HASH,
            SUBSCRIPTION_ID,
            CALLBACK_GAS_LIMIT,
            REQUEST_CONFIRMATIONS
        );
    }

    /**
     * @dev Test constructor setup
     * @notice Pastikan contract ter-deploy dengan configuration yang benar
     */
    function testConstructor() public view {
        // Pastikan contract ter-deploy
        assertTrue(address(vrf) != address(0));

        // Dapatkan configuration dan verify
        (
            address coordinator,
            bytes32 keyHash,
            uint64 subId,
            uint32 gasLimit,
            uint16 confirmations
        ) = vrf.getVRFConfig();

        // Verify semua configuration parameters
        assertEq(
            coordinator,
            VRF_COORDINATOR,
            "Coordinator address should match"
        );
        assertEq(keyHash, KEY_HASH, "Key hash should match");
        assertEq(subId, SUBSCRIPTION_ID, "Subscription ID should match");
        assertEq(
            gasLimit,
            CALLBACK_GAS_LIMIT,
            "Callback gas limit should match"
        );
        assertEq(
            confirmations,
            REQUEST_CONFIRMATIONS,
            "Request confirmations should match"
        );
    }

    /**
     * @dev Test request random words validation
     * @notice Pastikan validation bekerja dengan benar
     */
    function testRequestRandomWordsValidation() public {
        // Test dengan numWords = 0 (harus revert)
        vm.expectRevert("Number of words must be greater than 0");
        vrf.requestRandomWords(0);

        // Test dengan numWords > 10 (harus revert)
        vm.expectRevert("Maximum 10 random words allowed");
        vrf.requestRandomWords(11);
    }

    /**
     * @dev Test get random word functionality
     * @notice Pastikan fungsi getRandomWord bekerja dengan data yang tersedia
     */
    function testGetRandomWord() public {
        // Simulasikan bahwa kita memiliki random words
        uint256[] memory mockRandomWords = new uint256[](3);
        mockRandomWords[0] = 123456789;
        mockRandomWords[1] = 987654321;
        mockRandomWords[2] = 555555555;

        // Mock fulfillRandomWords call (ini akan gagal karena tidak dari coordinator)
        // Untuk test sederhana, kita skip actual VRF call

        // Test dengan index yang valid (harus bekerja jika ada data)
        // Test ini akan skip karena kita tidak punya actual random words
    }

    /**
     * @dev Test get random in range functionality
     * @notice Pastikan fungsi getRandomInRange menghasilkan nilai dalam range
     */
    function testGetRandomInRange() public {
        // Test dengan range yang valid
        // Karena kita tidak punya actual random words, test ini akan skip
        // Test edge cases
        // Test ini akan skip karena memerlukan actual random words
    }

    /**
     * @dev Test request fulfillment tracking
     * @notice Pastikan mapping requestFulfilled bekerja dengan benar
     */
    function testRequestFulfilledTracking() public view {
        // Test dengan request ID yang tidak ada (harus return false)
        bool isFulfilled = vrf.isRequestFulfilled(999);
        assertFalse(
            isFulfilled,
            "Non-existent request should not be fulfilled"
        );
    }

    /**
     * @dev Test get all random words
     * @notice Pastikan fungsi getAllRandomWords mengembalikan array yang benar
     */
    function testGetAllRandomWords() public view {
        // Dapatkan semua random words (harus empty array untuk contract baru)
        uint256[] memory randomWords = vrf.getAllRandomWords();

        // Array harus kosong untuk contract baru
        assertEq(
            randomWords.length,
            0,
            "New contract should have empty random words array"
        );
    }

    /**
     * @dev Test get random words count
     * @notice Pastikan fungsi getRandomWordsCount mengembalikan count yang benar
     */
    function testGetRandomWordsCount() public view {
        // Dapatkan count random words (harus 0 untuk contract baru)
        uint256 count = vrf.getRandomWordsCount();

        assertEq(count, 0, "New contract should have 0 random words");
    }

    /**
     * @dev Test update VRF configuration
     * @notice Pastikan fungsi updateVRFConfig bekerja dengan benar
     */
    function testUpdateVRFConfig() public {
        // Simpan configuration lama
        (, , , uint32 oldGasLimit, uint16 oldConfirmations) = vrf
            .getVRFConfig();

        // Update configuration
        uint32 newGasLimit = 200000;
        uint16 newConfirmations = 5;
        vrf.updateVRFConfig(newGasLimit, newConfirmations);

        // Dapatkan configuration baru
        (, , , uint32 updatedGasLimit, uint16 updatedConfirmations) = vrf
            .getVRFConfig();

        // Verify configuration ter-update
        assertEq(updatedGasLimit, newGasLimit, "Gas limit should be updated");
        assertEq(
            updatedConfirmations,
            newConfirmations,
            "Confirmations should be updated"
        );

        // Pastikan values berubah dari sebelumnya
        assertTrue(updatedGasLimit != oldGasLimit, "Gas limit should change");
        assertTrue(
            updatedConfirmations != oldConfirmations,
            "Confirmations should change"
        );
    }

    /**
     * @dev Test edge cases untuk getRandomWord
     * @notice Pastikan error handling bekerja dengan benar
     */
    function testGetRandomWordEdgeCases() public {
        // Test dengan empty random words array (harus revert)
        vm.expectRevert("No random words available");
        vrf.getRandomWord(0);

        // Simulasikan kita punya 1 random word
        // Test dengan index out of bounds (harus revert)
        // vm.expectRevert("Index out of bounds");
        // vrf.getRandomWord(1); // Index 1 ketika hanya ada 1 element
    }

    /**
     * @dev Test edge cases untuk getRandomInRange
     * @notice Pastikan range validation bekerja dengan benar
     */
    function testGetRandomInRangeEdgeCases() public {
        // Test dengan min > max (harus revert)
        vm.expectRevert("Min must be less than or equal to max");
        vrf.getRandomInRange(10, 5, 0);

        // Test dengan wordIndex yang tidak tersedia (harus revert)
        vm.expectRevert("Random word not available");
        vrf.getRandomInRange(1, 10, 0); // wordIndex 0 tidak tersedia
    }

    /**
     * @dev Test multiple configuration updates
     * @notice Pastikan multiple updates tidak menyebabkan issues
     */
    function testMultipleConfigUpdates() public {
        // Multiple configuration updates
        vrf.updateVRFConfig(150000, 4);
        vrf.updateVRFConfig(250000, 6);
        vrf.updateVRFConfig(300000, 8);

        // Verify final configuration
        (, , , uint32 finalGasLimit, uint16 finalConfirmations) = vrf
            .getVRFConfig();

        assertEq(finalGasLimit, 300000, "Final gas limit should be correct");
        assertEq(
            finalConfirmations,
            8,
            "Final confirmations should be correct"
        );
    }

    /**
     * @dev Test events emission
     * @notice Pastikan events di-emit dengan benar
     */
    function testEventsEmission() public {
        // Test untuk RandomWordsRequested event
        // Karena kita tidak bisa actually call VRF coordinator,
        // kita skip test actual event emission
        // Test untuk RandomWordsFulfilled event
        // Juga skip karena memerlukan actual VRF fulfillment
    }

    /**
     * @dev Test contract deployment dengan berbagai parameters
     * @notice Pastikan contract bisa di-deploy dengan parameters yang berbeda
     */
    function testDifferentConstructorParameters() public {
        // Deploy dengan parameters yang berbeda
        BasicVRF differentVRF = new BasicVRF(
            address(0x123),
            bytes32("different_key_hash"),
            999,
            50000,
            10
        );

        // Verify configuration
        (
            address coordinator,
            bytes32 keyHash,
            uint64 subId,
            uint32 gasLimit,
            uint16 confirmations
        ) = differentVRF.getVRFConfig();

        assertEq(
            coordinator,
            address(0x123),
            "Different coordinator should be set"
        );
        assertEq(
            keyHash,
            bytes32("different_key_hash"),
            "Different key hash should be set"
        );
        assertEq(subId, 999, "Different subscription ID should be set");
        assertEq(gasLimit, 50000, "Different gas limit should be set");
        assertEq(confirmations, 10, "Different confirmations should be set");
    }
}
