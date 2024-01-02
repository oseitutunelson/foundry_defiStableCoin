//SDPX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Script} from 'forge-std/Script.sol';
import {DSCEngine} from '../src/DSCEngine.sol';
import {DecentralizedStableCoin} from '../src/DecentralizedStablecoin.sol';
import {HelperConfig} from './HelperConfig.s.sol';

contract DeployDSC is Script{
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;


    function run() external returns (DSCEngine,DecentralizedStableCoin,HelperConfig){
         HelperConfig helperConfig = new HelperConfig(); // This comes with our mocks!

        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerKey) =
            helperConfig.activeNetworkConfig();
        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];
        vm.startBroadcast(deployerKey);
        DecentralizedStableCoin dsc = new DecentralizedStableCoin();
        DSCEngine dscEngine = new DSCEngine(tokenAddresses,priceFeedAddresses,address(dsc));
       
        dsc.transferOwnership(address(dscEngine)); 
        vm.stopBroadcast();
        return (dscEngine,dsc,helperConfig);
    }
}