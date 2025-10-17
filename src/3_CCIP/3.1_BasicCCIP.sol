// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Import interfaces untuk Chainlink CCIP
import {IRouterClient} from "@chainlink/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts/src/v0.8/ccip/applications/CCIPReceiver.sol";

/**
 * @title BasicCCIP
 * @dev Contract dasar untuk cross-chain messaging menggunakan Chainlink CCIP
 * @notice Contoh implementasi CCIP untuk mengirim dan menerima pesan antar chain
 */
contract BasicCCIP is CCIPReceiver {
    // Event untuk melacak pesan yang dikirim dan diterima
    event MessageSent(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        string message,
        address feeToken,
        uint256 fees
    );

    event MessageReceived(
        bytes32 indexed messageId,
        uint64 indexed sourceChainSelector,
        address sender,
        string message
    );

    // State variables
    bytes32 public lastReceivedMessageId;
    string public lastReceivedMessage;
    uint64 public lastSourceChainSelector;

    /**
     * @dev Constructor untuk setup CCIP router
     * @param _router Address CCIP Router contract
     */
    constructor(address _router) CCIPReceiver(_router) {}

    /**
     * @dev Fungsi untuk mengirim pesan cross-chain
     * @param _destinationChainSelector Chain selector untuk destination chain
     * @param _receiver Address contract penerima di destination chain
     * @param _message String message yang akan dikirim
     * @param _feeToken Address token untuk membayar fee (address(0) untuk native)
     * @return messageId ID dari message yang dikirim
     */
    function sendMessage(
        uint64 _destinationChainSelector,
        address _receiver,
        string calldata _message,
        address _feeToken
    ) external payable returns (bytes32 messageId) {
        // Buat CCIP message
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver), // Encode receiver address
            data: abi.encode(_message), // Encode message data
            tokenAmounts: new Client.EVMTokenAmount[](0), // No token transfer
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000}) // Gas limit untuk execution
            ),
            feeToken: _feeToken // Token untuk membayar fee
        });

        // Get estimated fee
        uint256 fee = IRouterClient(getRouter()).getFee(
            _destinationChainSelector,
            message
        );

        // Validasi bahwa cukup fee dibayar
        require(msg.value >= fee, "Insufficient fee");

        // Kirim message menggunakan CCIP router
        messageId = IRouterClient(getRouter()).ccipSend{value: fee}(
            _destinationChainSelector,
            message
        );

        // Emit event untuk tracking
        emit MessageSent(
            messageId,
            _destinationChainSelector,
            _receiver,
            _message,
            _feeToken,
            fee
        );

        // Kembalikan kelebihan ETH ke sender
        if (msg.value > fee) {
            payable(msg.sender).transfer(msg.value - fee);
        }

        return messageId;
    }

    /**
     * @dev Callback function yang dipanggil oleh CCIP router ketika message diterima
     * @param message CCIP message yang diterima
     */
    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal override {
        // Extract message ID dan source chain
        bytes32 messageId = message.messageId;
        uint64 sourceChainSelector = message.sourceChainSelector;

        // Decode sender address dari message
        address sender = abi.decode(message.sender, (address));

        // Decode message data
        string memory receivedMessage = abi.decode(message.data, (string));

        // Update state dengan message yang diterima
        lastReceivedMessageId = messageId;
        lastReceivedMessage = receivedMessage;
        lastSourceChainSelector = sourceChainSelector;

        // Emit event untuk notifikasi
        emit MessageReceived(
            messageId,
            sourceChainSelector,
            sender,
            receivedMessage
        );
    }

    /**
     * @dev Fungsi untuk mendapatkan estimated fee untuk mengirim message
     * @param _destinationChainSelector Chain selector untuk destination
     * @param _receiver Address penerima
     * @param _message Message yang akan dikirim
     * @param _feeToken Token untuk membayar fee
     * @return fee Estimated fee dalam wei
     */
    function getMessageFee(
        uint64 _destinationChainSelector,
        address _receiver,
        string calldata _message,
        address _feeToken
    ) external view returns (uint256 fee) {
        // Buat message structure sama seperti di sendMessage
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: abi.encode(_message),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000})
            ),
            feeToken: _feeToken
        });

        // Get estimated fee dari router
        fee = IRouterClient(getRouter()).getFee(
            _destinationChainSelector,
            message
        );

        return fee;
    }

    /**
     * @dev Fungsi untuk mendapatkan informasi tentang message terakhir yang diterima
     * @return messageId ID message terakhir
     * @return message Content message terakhir
     * @return sourceChain Chain selector sumber
     * @return timestamp Waktu ketika message diterima
     */
    function getLastReceivedMessageInfo()
        external
        view
        returns (
            bytes32 messageId,
            string memory message,
            uint64 sourceChain,
            uint256 timestamp
        )
    {
        messageId = lastReceivedMessageId;
        message = lastReceivedMessage;
        sourceChain = lastSourceChainSelector;
        timestamp = block.timestamp; // Catatan: ini waktu sekarang, bukan waktu penerimaan
    }

    /**
     * @dev Fungsi untuk mengecek apakah contract ini mendukung chain tertentu
     * @param _chainSelector Chain selector yang ingin dicek
     * @return isSupported True jika chain supported
     */
    function isChainSupported(
        uint64 _chainSelector
    ) external view returns (bool isSupported) {
        // Dalam implementasi real, kita bisa check terhadap whitelist chains
        // Untuk simplicity, return true untuk semua (bisa di-modify)
        return true;
    }

    /**
     * @dev Fungsi untuk withdraw ETH yang tersimpan di contract
     * @param _to Address tujuan withdraw
     * @param _amount Amount ETH yang akan di-withdraw
     */
    function withdrawETH(address payable _to, uint256 _amount) external {
        // Dalam implementasi real, tambahkan access control
        require(_amount <= address(this).balance, "Insufficient balance");
        _to.transfer(_amount);
    }

    /**
     * @dev Receive function untuk menerima ETH
     */
    receive() external payable {}
}
