// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {OFTTokenBridge} from "@voting-chain/setup/ToucanRelaySetup.sol";
import {SendParam, MessagingFee, MessagingReceipt, OFTReceipt} from "@lz-oft/interfaces/IOFT.sol";
import {OptionsBuilder} from "@lz-oapp/libs/OptionsBuilder.sol";
import {Script} from "forge-std/Script.sol";
import "forge-std/console2.sol";

contract ReverseTransfer is Script {
    address deployer;

    modifier broadcast() {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployer);
        _;
        vm.stopBroadcast();
    }

    function run() public broadcast {
        uint256 amount = 1000000000000000000000; // 1000 tokens
        
        // Get addresses from environment
        address chain2Bridge = vm.envAddress("CHAIN_2_BRIDGE");
        address chain2Token = vm.envAddress("CHAIN_2_TOKEN");
        uint32 chain1Eid = uint32(vm.envUint("CHAIN_1_EID"));
        
        console2.log("Transferring", amount / 10**18, "tokens from Chain 2 to Chain 1");
        console2.log("Deployer:", deployer);
        console2.log("Bridge:", chain2Bridge);
        console2.log("Token:", chain2Token);
        console2.log("Chain 1 EID:", chain1Eid);
        
        // Create LayerZero options
        bytes memory lzOptions = OptionsBuilder.addExecutorLzReceiveOption(OptionsBuilder.newOptions(), 200000, 0);
        
        // Prepare the transfer parameters
        SendParam memory sendParam = SendParam({
            dstEid: chain1Eid,
            to: addressToBytes32(deployer), // recipient on Chain 1
            amountLD: amount,
            minAmountLD: amount,
            extraOptions: lzOptions,
            composeMsg: "0x",
            oftCmd: "0x"
        });
        
        // Get fee quote
        MessagingFee memory msgFee = OFTTokenBridge(chain2Bridge).quoteSend(sendParam, false);
        console2.log("Estimated native fee:", msgFee.nativeFee);
        
        // Execute the transfer
        (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt) = OFTTokenBridge(chain2Bridge).send{value: msgFee.nativeFee}(
            sendParam,
            msgFee,
            payable(deployer)
        );
        
        console2.log("Transfer initiated!");
        console2.log("Message GUID:", vm.toString(msgReceipt.guid));
        console2.log("Amount sent:", oftReceipt.amountSentLD);
        console2.log("Amount received:", oftReceipt.amountReceivedLD);
    }

    function addressToBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    // Check Chain 2 balance
    function checkChain2Balance() public view {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddr = vm.addr(deployerPrivateKey);
        address chain2Token = vm.envAddress("CHAIN_2_TOKEN");
        
        console2.log("=== Chain 2 Token Balance ===");
        console2.log("Deployer address:", deployerAddr);
        console2.log("Chain 2 token address:", chain2Token);
        
        uint256 balance = IERC20(chain2Token).balanceOf(deployerAddr);
        console2.log("Chain 2 balance:", balance / 10**18, "tokens");
    }
} 