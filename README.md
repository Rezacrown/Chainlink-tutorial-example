# 🚀 Chainlink Bootcamp - Panduan Lengkap

## 📚 Daftar Isi

### 1. [Price Feed](docs/1-price-feed.md)

- **1.1** - Basic Price Feed ([src/1_PriceFeed/1.1_BasicPriceFeed.sol](src/1_PriceFeed/1.1_BasicPriceFeed.sol))
- **1.2** - DeFi Lending Oracle ([src/1_PriceFeed/1.2_LendingOracle.sol](src/1_PriceFeed/1.2_LendingOracle.sol))
- **1.3** - Stablecoin Peg ([src/1_PriceFeed/1.3_StablecoinPeg.sol](src/1_PriceFeed/1.3_StablecoinPeg.sol))

### 2. [VRF (Verifiable Random Function)](docs/2-vrf.md)

- **2.1** - Basic VRF ([src/2_VRF/2.1_BasicVRF.sol](src/2_VRF/2.1_BasicVRF.sol))
- **2.2** - NFT Random Minter ([src/2_VRF/2.2_NFTMinter.sol](src/2_VRF/2.2_NFTMinter.sol))
- **2.3** - Lottery Game ([src/2_VRF/2.3_LotteryGame.sol](src/2_VRF/2.3_LotteryGame.sol))

### 3. [CCIP (Cross-Chain Interoperability Protocol)](docs/3-ccip.md)

- **3.1** - Basic CCIP Messaging ([src/3_CCIP/3.1_BasicCCIP.sol](src/3_CCIP/3.1_BasicCCIP.sol))
- **3.2** - Cross-Chain Token Bridge ([src/3_CCIP/3.2_TokenBridge.sol](src/3_CCIP/3.2_TokenBridge.sol))
- **3.3** - Multi-Chain Governance ([src/3_CCIP/3.3_MultiChainGovernance.sol](src/3_CCIP/3.3_MultiChainGovernance.sol))

### 4. [Chainlink Functions](docs/4-functions.md)

- **4.1** - Basic Functions ([src/4_Functions/4.1_BasicFunctions.sol](src/4_Functions/4.1_BasicFunctions.sol))
- **4.2** - Weather Insurance ([src/4_Functions/4.2_WeatherInsurance.sol](src/4_Functions/4.2_WeatherInsurance.sol))
- **4.3** - Sports Betting ([src/4_Functions/4.3_SportsBetting.sol](src/4_Functions/4.3_SportsBetting.sol))

### 5. [Chainlink Automation](docs/5-automation.md)

- **5.1** - Basic Automation ([src/5_Automation/5.1_BasicAutomation.sol](src/5_Automation/5.1_BasicAutomation.sol))
- **5.2** - Auto Compound Vault ([src/5_Automation/5.2_AutoCompound.sol](src/5_Automation/5.2_AutoCompound.sol))
- **5.3** - Liquidation Bot ([src/5_Automation/5.3_LiquidationBot.sol](src/5_Automation/5.3_LiquidationBot.sol))

## 🎯 Cara Belajar

### Urutan yang Disarankan:

1. **Mulai dari Price Feed** (Fitur paling dasar dan umum)
2. **Lanjut ke VRF** (Untuk randomness dan gaming)
3. **Pelajari CCIP** (Cross-chain communication)
4. **Explore Functions** (Off-chain computation)
5. **Akhiri dengan Automation** (Smart contract automation)

### Setiap File Memiliki:

- ✅ Penomoran jelas di nama file
- ✅ Komentar per line dalam Bahasa Indonesia
- ✅ Contoh use case praktis
- ✅ Test file untuk verifikasi
- ✅ Link ke dokumentasi detail

## 🛠 Setup Environment

```bash
# Install dependencies
forge install

# Build project
forge build

# Run tests
forge test

# Run specific test
forge test --match-test testGetEthPrice
```

## 📖 Prerequisites

- Basic knowledge of Solidity
- Understanding of smart contracts
- Foundry framework installed
- Testnet ETH untuk deployment

## 🔗 Resources

- [Chainlink Documentation](https://docs.chain.link/)
- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)

---

**Happy Learning! 🎉**
