//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

//Deploy mock when we are testing on anvil local chain
//other wise, use testnet/mainnet network
import {Script} from "forge-std/Script.sol";

import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public ActiveNetworkConfig;

    uint8 public constant DECIMAL_NUMBER = 8;

    int256 public constant INTIAL_PRICE = 2000e8;

    //address public TEST_ADDRESS = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    struct NetworkConfig {
        address priceFeed; //ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            ActiveNetworkConfig = getSepoliaConfig();
        } else {
            ActiveNetworkConfig = getAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        //testnet
        //priceFeed
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});

        return sepoliaConfig;
    }

    function getAnvilConfig() public returns (NetworkConfig memory) {
        if (ActiveNetworkConfig.priceFeed != address(0)) {
            return ActiveNetworkConfig;
        }
        //Mock ---Anvil
        //priceFeed
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMAL_NUMBER, INTIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});

        return anvilConfig;
    }
}
