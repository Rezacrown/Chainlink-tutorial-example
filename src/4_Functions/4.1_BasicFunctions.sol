// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Import interfaces untuk Chainlink Functions
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

/**
 * @title BasicFunctions
 * @dev Contract dasar untuk Chainlink Functions
 * @notice Contoh implementasi Functions untuk memanggil API eksternal
 */
contract BasicFunctions is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    // Event untuk melacak request dan response
    // event RequestSent(bytes32 indexed requestId);
    event ResponseReceived(
        bytes32 indexed requestId,
        bytes response,
        bytes err
    );
    event RequestFailed(bytes32 indexed requestId, bytes err);

    // State variables untuk menyimpan data
    bytes32 public lastRequestId;
    bytes public lastResponse;
    bytes public lastError;
    string public lastDecodedResponse;

    // Configuration untuk Functions
    uint64 public subscriptionId;
    uint32 public gasLimit;
    bytes32 public donID;

    /**
     * @dev Constructor untuk setup Functions configuration
     * @param _router Address Functions Router contract
     * @param _subscriptionId Subscription ID untuk pembayaran
     * @param _gasLimit Gas limit untuk callback function
     * @param _donID DON ID untuk functions execution
     */
    constructor(
        address _router,
        uint64 _subscriptionId,
        uint32 _gasLimit,
        bytes32 _donID
    ) FunctionsClient(_router) ConfirmedOwner(msg.sender) 
    {
        subscriptionId = _subscriptionId;
        gasLimit = _gasLimit;
        donID = _donID;
    }

    /**
     * @dev Fungsi untuk mengirim request ke Chainlink Functions
     * @param _sourceCode JavaScript source code yang akan dijalankan
     * @param _secrets Encrypted secrets untuk API keys (jika ada)
     * @param _args Arguments untuk source code
     * @return requestId ID dari request yang dibuat
     */
    function sendRequest(
        string calldata _sourceCode,
        bytes calldata _secrets,
        string[] calldata _args
    ) external returns (bytes32 requestId) {
        // Validasi input parameters
        require(bytes(_sourceCode).length > 0, "Source code cannot be empty");

        // Buat Functions request
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(_sourceCode);
        
        // Set request parameters
        if (_secrets.length > 0) {
            req.addSecretsReference(_secrets);
        }
        if (_args.length > 0) {
            req.setArgs(_args);
        }

        // Kirim request ke Functions router
        requestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        // Simpan request ID
        lastRequestId = requestId;

        // Emit event untuk tracking
        emit RequestSent(requestId);

        return requestId;
    }

    /**
     * @dev Callback function yang dipanggil oleh Chainlink Functions
     * @param _requestId ID dari request yang dipenuhi
     * @param _response Response data dari functions execution
     * @param _err Error message (jika ada)
     */
    function fulfillRequest(
        bytes32 _requestId,
        bytes memory _response,
        bytes memory _err
    ) internal override {
        // Update state dengan response dan error
        lastResponse = _response;
        lastError = _err;

        // Decode response jika tidak ada error
        if (_err.length == 0 && _response.length > 0) {
            // Contoh: decode response sebagai string
            // Bisa di-modify sesuai dengan expected response type
            lastDecodedResponse = string(_response);

            // Emit success event
            emit ResponseReceived(_requestId, _response, _err);
        } else {
            // Emit failure event
            emit RequestFailed(_requestId, _err);
        }
    }

    /**
     * @dev Fungsi untuk mendapatkan response sebagai string
     * @return decodedResponse Response yang sudah di-decode sebagai string
     */
    function getResponseAsString()
        external
        view
        returns (string memory decodedResponse)
    {
        return lastDecodedResponse;
    }

    /**
     * @dev Fungsi untuk mendapatkan response sebagai uint256
     * @return decodedResponse Response yang sudah di-decode sebagai uint256
     * @notice Akan revert jika response tidak bisa di-decode sebagai uint256
     */
    function getResponseAsUint256()
        external
        view
        returns (uint256 decodedResponse)
    {
        require(lastResponse.length > 0, "No response available");
        decodedResponse = abi.decode(lastResponse, (uint256));
        return decodedResponse;
    }

    /**
     * @dev Fungsi untuk mengecek apakah request terakhir berhasil
     * @return isSuccess True jika request berhasil, false jika gagal
     */
    function isLastRequestSuccessful() external view returns (bool isSuccess) {
        return (lastError.length == 0 && lastResponse.length > 0);
    }

    /**
     * @dev Fungsi untuk mendapatkan error message terakhir
     * @return errorMessage Error message sebagai string
     */
    function getLastErrorMessage()
        external
        view
        returns (string memory errorMessage)
    {
        return string(lastError);
    }

    /**
     * @dev Fungsi untuk update Functions configuration
     * @param _subscriptionId Subscription ID baru
     * @param _gasLimit Gas limit baru
     * @param _donID DON ID baru
     */
    function updateConfig(
        uint64 _subscriptionId,
        uint32 _gasLimit,
        bytes32 _donID
    ) external {
        // Dalam implementasi real, tambahkan modifier onlyOwner
        // require(msg.sender == owner, "Only owner can update config");

        subscriptionId = _subscriptionId;
        gasLimit = _gasLimit;
        donID = _donID;
    }

    /**
     * @dev Fungsi untuk mendapatkan current configuration
     * @return currentSubscriptionId Current subscription ID
     * @return currentGasLimit Current gas limit
     * @return currentDonID Current DON ID
     */
    function getConfig()
        external
        view
        returns (
            uint64 currentSubscriptionId,
            uint32 currentGasLimit,
            bytes32 currentDonID
        )
    {
        currentSubscriptionId = subscriptionId;
        currentGasLimit = gasLimit;
        currentDonID = donID;
    }

    /**
     * @dev Contoh JavaScript source code untuk mendapatkan harga ETH dari CoinGecko
     * @return sourceCode JavaScript source code sebagai string
     */
    function getExampleSourceCode()
        external
        pure
        returns (string memory sourceCode)
    {
        return
            string(
                abi.encodePacked(
                    "const coinGeckoResponse = await Functions.makeHttpRequest({",
                    "  url: 'https://api.coingecko.com/api/v3/simple/price',",
                    "  params: {",
                    "    ids: 'ethereum',",
                    "    vs_currencies: 'usd'",
                    "  }",
                    "});",
                    "",
                    "if (coinGeckoResponse.error) {",
                    "  throw Error('API request failed');",
                    "}",
                    "",
                    "const price = coinGeckoResponse.data.ethereum.usd;",
                    "return Functions.encodeUint256(Math.round(price * 100)); // Return in cents"
                )
            );
    }

    /**
     * @dev Contoh JavaScript source code untuk mendapatkan data cuaca
     * @return sourceCode JavaScript source code sebagai string
     */
    function getWeatherExampleSourceCode()
        external
        pure
        returns (string memory sourceCode)
    {
        return
            string(
                abi.encodePacked(
                    "// Contoh: Get weather data dari OpenWeatherMap",
                    "// Note: Butuh API key yang disimpan di secrets",
                    "const weatherResponse = await Functions.makeHttpRequest({",
                    "  url: `https://api.openweathermap.org/data/2.5/weather`,",
                    "  params: {",
                    "    q: args[0], // City name dari arguments",
                    "    appid: secrets.apiKey, // API key dari secrets",
                    "    units: 'metric'",
                    "  }",
                    "});",
                    "",
                    "if (weatherResponse.error) {",
                    "  throw Error('Weather API request failed');",
                    "}",
                    "",
                    "const temperature = weatherResponse.data.main.temp;",
                    "return Functions.encodeUint256(Math.round(temperature));"
                )
            );
    }
}
