//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {Script} from "forge-std/Script.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";


contract HelperConfig is Script{
    struct NetworkConfig{
       address wethPriceFeed;
       address wbtcPriceFeed;
       address wethAddress;
       address wbtcAddress;
       uint256 deployerKey;
    }

    constructor(){
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaPriceFeed();
        }else{
            activeNetworkConfig = getOrCreateAnvilChain();
        }
    }

    uint256 public DEFAULT_ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    NetworkConfig public activeNetworkConfig;

    function getSepoliaPriceFeed() public view returns (NetworkConfig memory){
        return NetworkConfig({
            wethPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, // ETH / USD
            wbtcPriceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            wethAddress: 0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            wbtcAddress: 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getOrCreateAnvilChain() public  returns (NetworkConfig memory anvilNetworkConfig){
         if (activeNetworkConfig.wethPriceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator ethUsdPriceFeed = new MockV3Aggregator(
            8,
            2000e8
        );
        ERC20Mock wethMock = new ERC20Mock("WETH", "WETH", msg.sender, 1000e8);

        MockV3Aggregator btcUsdPriceFeed = new MockV3Aggregator(
            8,1000e8
        );
        ERC20Mock wbtcMock = new ERC20Mock("WBTC", "WBTC", msg.sender, 1000e8);
        vm.stopBroadcast();

        anvilNetworkConfig = NetworkConfig({
            wethPriceFeed: address(ethUsdPriceFeed), // ETH / USD
            wethAddress: address(wethMock),
            wbtcPriceFeed: address(btcUsdPriceFeed),
            wbtcAddress: address(wbtcMock),
            deployerKey: DEFAULT_ANVIL_KEY
        });
    
    }
}