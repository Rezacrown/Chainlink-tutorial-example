// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Import interfaces untuk Chainlink VRF V2 Plus
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title BasicVRF
 * @dev Contract dasar untuk mendapatkan random numbers dari Chainlink VRF
 * @notice Contoh implementasi VRF untuk request randomness sederhana
 */
contract BasicVRF is VRFConsumerBaseV2Plus {
    // Event untuk melacak request dan fulfillment
    event RandomWordsRequested(uint256 requestId, uint32 numWords);
    event RandomWordsFulfilled(uint256 requestId, uint256[] randomWords);

    // VRF configuration variables
    address public vrfCoordinator; // Address VRF Coordinator
    bytes32 public keyHash; // Key hash untuk VRF
    uint64 public subscriptionId; // Subscription ID untuk pembayaran
    uint32 public callbackGasLimit; // Gas limit untuk callback function
    uint16 public requestConfirmations; // Jumlah block confirmations

    // State variables untuk menyimpan random words
    uint256 public lastRequestId; // ID request terakhir
    uint256[] public lastRandomWords; // Array random words terakhir
    mapping(uint256 => bool) public requestFulfilled; // Track fulfilled requests

    /**
     * @dev Constructor untuk setup VRF configuration
     * @param _vrfCoordinator Address VRF Coordinator contract
     * @param _keyHash Key hash untuk VRF (gas lane)
     * @param _subscriptionId Subscription ID untuk pembayaran
     * @param _callbackGasLimit Gas limit untuk fulfillRandomWords
     * @param _requestConfirmations Jumlah block confirmations
     */
    constructor(
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        // Set VRF configuration parameters
        vrfCoordinator = _vrfCoordinator;
        keyHash = _keyHash;
        subscriptionId = _subscriptionId;
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
    }

    /**
     * @dev Fungsi untuk request random words dari Chainlink VRF
     * @param _numWords Jumlah random words yang diminta
     * @return requestId ID dari request yang dibuat
     * @notice Hanya owner yang bisa memanggil fungsi ini (bisa di-modify sesuai kebutuhan)
     */
    function requestRandomWords(
        uint32 _numWords
    ) external returns (uint256 requestId) {
        // Validasi input parameters
        require(_numWords > 0, "Number of words must be greater than 0");
        require(_numWords <= 10, "Maximum 10 random words allowed");

        // Prepare extra arguments untuk VRF request
        // nativePayment: false berarti bayar dengan LINK token
        bytes memory extraArgs = VRFV2PlusClient._argsToBytes(
            VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
        );

        // Membuat VRF request ke coordinator
        // Fungsi ini akan mengembalikan requestId dan request price
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash, // Gas lane key hash
                subId: subscriptionId, // Subscription ID
                requestConfirmations: requestConfirmations, // Block confirmations
                callbackGasLimit: callbackGasLimit, // Gas limit untuk callback
                numWords: _numWords, // Jumlah random words
                extraArgs: extraArgs // Additional arguments
            })
        );

        // Simpan request ID dan reset fulfillment status
        lastRequestId = requestId;
        requestFulfilled[requestId] = false;

        // Emit event untuk tracking
        emit RandomWordsRequested(requestId, _numWords);

        return requestId;
    }

    /**
     * @dev Callback function yang dipanggil oleh VRF Coordinator
     * @param _requestId ID dari request yang dipenuhi
     * @param _randomWords Array of random words yang dihasilkan
     * @notice Hanya VRF Coordinator yang bisa memanggil fungsi ini
     */
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] calldata _randomWords
    ) internal override {
        // Validasi bahwa request belum dipenuhi
        require(!requestFulfilled[_requestId], "Request already fulfilled");

        // Update state dengan random words yang diterima
        lastRandomWords = _randomWords;
        requestFulfilled[_requestId] = true;

        // Emit event untuk notifikasi
        emit RandomWordsFulfilled(_requestId, _randomWords);
    }

    /**
     * @dev Fungsi untuk mendapatkan random word tertentu dari hasil terakhir
     * @param index Index dari random word yang ingin diambil (0-based)
     * @return randomWord Random word pada index tertentu
     */
    function getRandomWord(
        uint256 index
    ) public view returns (uint256 randomWord) {
        // Validasi bahwa array tidak kosong dan index valid
        require(lastRandomWords.length > 0, "No random words available");
        require(index < lastRandomWords.length, "Index out of bounds");

        return lastRandomWords[index];
    }

    /**
     * @dev Fungsi untuk mendapatkan random number dalam range tertentu
     * @param min Nilai minimum (inclusive)
     * @param max Nilai maksimum (inclusive)
     * @param wordIndex Index random word yang akan digunakan
     * @return randomInRange Random number dalam range [min, max]
     */
    function getRandomInRange(
        uint256 min,
        uint256 max,
        uint256 wordIndex
    ) public view returns (uint256 randomInRange) {
        // Validasi range
        require(min <= max, "Min must be less than or equal to max");
        require(
            lastRandomWords.length > wordIndex,
            "Random word not available"
        );

        // Dapatkan random word
        uint256 randomWord = getRandomWord(wordIndex);

        // Calculate range size
        uint256 range = max - min + 1;

        // Generate random number dalam range menggunakan modulo
        randomInRange = (randomWord % range) + min;

        return randomInRange;
    }

    /**
     * @dev Fungsi untuk mengecek status fulfillment dari request tertentu
     * @param _requestId ID request yang ingin dicek
     * @return isFulfilled True jika request sudah dipenuhi, false jika belum
     */
    function isRequestFulfilled(
        uint256 _requestId
    ) public view returns (bool isFulfilled) {
        return requestFulfilled[_requestId];
    }

    /**
     * @dev Fungsi untuk mendapatkan semua random words terakhir
     * @return randomWords Array of semua random words terakhir
     */
    function getAllRandomWords()
        public
        view
        returns (uint256[] memory randomWords)
    {
        return lastRandomWords;
    }

    /**
     * @dev Fungsi untuk mendapatkan jumlah random words yang tersedia
     * @return count Jumlah random words yang tersimpan
     */
    function getRandomWordsCount() public view returns (uint256 count) {
        return lastRandomWords.length;
    }

    /**
     * @dev Fungsi untuk mendapatkan VRF configuration
     * @return coordinator Address VRF Coordinator
     * @return keyHashBytes Key hash yang digunakan
     * @return subId Subscription ID
     * @return gasLimit Callback gas limit
     * @return confirmations Request confirmations
     */
    function getVRFConfig()
        public
        view
        returns (
            address coordinator,
            bytes32 keyHashBytes,
            uint64 subId,
            uint32 gasLimit,
            uint16 confirmations
        )
    {
        coordinator = vrfCoordinator;
        keyHashBytes = keyHash;
        subId = subscriptionId;
        gasLimit = callbackGasLimit;
        confirmations = requestConfirmations;
    }

    /**
     * @dev Fungsi untuk mengupdate VRF configuration (hanya owner)
     * @param _callbackGasLimit Gas limit baru untuk callback
     * @param _requestConfirmations Jumlah block confirmations baru
     */
    function updateVRFConfig(
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations
    ) external {
        // Dalam implementasi real, tambahkan modifier onlyOwner
        // require(msg.sender == owner, "Only owner can update config");

        // Update configuration
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
    }
}
