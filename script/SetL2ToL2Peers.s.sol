// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {IDAO} from "@aragon/osx/core/dao/IDAO.sol";
import {Multisig} from "@aragon/osx/plugins/governance/multisig/Multisig.sol";
import {IOAppCore} from "@lz-oapp/interfaces/IOAppCore.sol";
import "forge-std/console2.sol";
import "@helpers/OSxHelpers.sol";
import {DAO} from "@aragon/osx/core/dao/DAO.sol";
import "@utils/converters.sol";

contract SetL2ToL2Peers is Script {
    
    address deployer;
    
    modifier broadcast() {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        deployer = vm.addr(deployerPrivateKey);
        
        vm.startBroadcast(deployer);
        _;
        vm.stopBroadcast();
    }
    
    function run() public broadcast {
        uint256 direction = vm.envUint("PEER_DIRECTION");

        if (direction == 0) {
            console2.log("Setting up Chain 1 -> Chain 2 peer");
            setChain1ToChain2Peer();
        } else if (direction == 1) {
            console2.log("Setting up Chain 2 -> Chain 1 peer");
            setChain2ToChain1Peer();
        } else {
            revert("PEER_DIRECTION must be 0 (CHAIN1_TO_CHAIN2) or 1 (CHAIN2_TO_CHAIN1)");
        }
    }
    
    function setChain1ToChain2Peer() public {
        console2.log("Setting Chain 1 bridge peer to Chain 2...");
        
        // Get addresses from environment
        address chain1Bridge = vm.envAddress("CHAIN_1_BRIDGE");
        address chain1Dao = vm.envAddress("CHAIN_1_DAO");
        address chain1Psp = vm.envAddress("CHAIN_1_PSP");
        address chain1Multisig = vm.envAddress("CHAIN_1_MULTISIG");
        address chain2Bridge = vm.envAddress("CHAIN_2_BRIDGE");
        uint32 chain2Eid = uint32(vm.envUint("CHAIN_2_EID"));
        uint32 chain1Eid = uint32(vm.envUint("CHAIN_1_EID"));
        
        require(chain1Bridge != address(0) && chain2Bridge != address(0), "invalid bridge");
        require(chain1Dao != address(0) && chain1Multisig != address(0), "invalid dao/multisig");
        require(chain1Psp != address(0), "invalid PSP");
        require(chain1Eid != 0 && chain2Eid != 0, "invalid EID");
        
        console2.log("Chain 1 Bridge:", chain1Bridge);
        console2.log("Chain 2 Bridge:", chain2Bridge);
        console2.log("Chain 2 EID:", chain2Eid);
        
        // Create proposal to set peer on Chain 1 DAO
        IDAO.Action[] memory actions = new IDAO.Action[](1);
        
        actions[0] = IDAO.Action({
            to: chain1Bridge,
            value: 0,
            data: abi.encodeCall(
                IOAppCore.setPeer,
                (chain2Eid, addressToBytes32(chain2Bridge))
            )
        });
        
        IDAO.Action[] memory wrappedActions = wrapGrantRevokeRoot(DAO(payable(chain1Dao)), chain1Psp, actions);
        
        // Create and execute proposal on Chain 1
        Multisig multisig = Multisig(chain1Multisig);
        
        uint256 proposalId = multisig.createProposal({
            _metadata: "",
            _actions: wrappedActions,
            _allowFailureMap: 0,
            _approveProposal: true,
            _tryExecution: true,
            _startDate: 0,
            _endDate: uint64(block.timestamp + 30 minutes)
        });
        
        console2.log("Chain 1 proposal created with ID:", proposalId);
    }
    
    function setChain2ToChain1Peer() public {
        console2.log("Setting Chain 2 bridge peer to Chain 1...");
        
        // Get addresses from environment
        address chain2Bridge = vm.envAddress("CHAIN_2_BRIDGE");
        address chain2Dao = vm.envAddress("CHAIN_2_DAO");
        address chain2Psp = vm.envAddress("CHAIN_2_PSP");
        address chain2Multisig = vm.envAddress("CHAIN_2_MULTISIG");
        address chain1Bridge = vm.envAddress("CHAIN_1_BRIDGE");
        uint32 chain1Eid = uint32(vm.envUint("CHAIN_1_EID"));
        uint32 chain2Eid = uint32(vm.envUint("CHAIN_2_EID"));
        
        require(chain2Bridge != address(0) && chain1Bridge != address(0), "invalid bridge");
        require(chain2Dao != address(0) && chain2Multisig != address(0), "invalid dao/multisig");
        require(chain2Psp != address(0), "invalid PSP");
        require(chain1Eid != 0 && chain2Eid != 0, "invalid EID");
        
        console2.log("Chain 2 Bridge:", chain2Bridge);
        console2.log("Chain 1 Bridge:", chain1Bridge);
        console2.log("Chain 1 EID:", chain1Eid);
        
        // Create proposal to set peer on Chain 2 DAO
        IDAO.Action[] memory actions = new IDAO.Action[](1);
        
        actions[0] = IDAO.Action({
            to: chain2Bridge,
            value: 0,
            data: abi.encodeCall(
                IOAppCore.setPeer,
                (chain1Eid, addressToBytes32(chain1Bridge))
            )
        });
        
        IDAO.Action[] memory wrappedActions = wrapGrantRevokeRoot(DAO(payable(chain2Dao)), chain2Psp, actions);
        
        // Create and execute proposal on Chain 2
        Multisig multisig = Multisig(chain2Multisig);
        
        uint256 proposalId = multisig.createProposal({
            _metadata: "",
            _actions: wrappedActions,
            _allowFailureMap: 0,
            _approveProposal: true,
            _tryExecution: true,
            _startDate: 0,
            _endDate: uint64(block.timestamp + 30 minutes)
        });
        
        console2.log("Chain 2 proposal created with ID:", proposalId);
    }
    

    
    // Verification functions
    function verifyChain1Peer() public view {
        address chain1Bridge = vm.envAddress("CHAIN_1_BRIDGE");
        address chain2Bridge = vm.envAddress("CHAIN_2_BRIDGE");
        uint32 chain2Eid = uint32(vm.envUint("CHAIN_2_EID"));
        
        bytes32 peer = IOAppCore(chain1Bridge).peers(chain2Eid);
        console2.log("Chain 1 bridge peer for Chain 2 (EID", chain2Eid, "):", vm.toString(peer));
        
        if (peer == addressToBytes32(chain2Bridge)) {
            console2.log("Chain 1 bridge correctly configured for Chain 2");
        } else {
            console2.log("Chain 1 bridge NOT configured for Chain 2");
        }
    }
    
    function verifyChain2Peer() public view {
        address chain2Bridge = vm.envAddress("CHAIN_2_BRIDGE");
        address chain1Bridge = vm.envAddress("CHAIN_1_BRIDGE");
        uint32 chain1Eid = uint32(vm.envUint("CHAIN_1_EID"));
        
        bytes32 peer = IOAppCore(chain2Bridge).peers(chain1Eid);
        console2.log("Chain 2 bridge peer for Chain 1 (EID", chain1Eid, "):", vm.toString(peer));
        
        if (peer == addressToBytes32(chain1Bridge)) {
            console2.log("Chain 2 bridge correctly configured for Chain 1");
        } else {
            console2.log("Chain 2 bridge NOT configured for Chain 1");
        }
    }
    
    function verifyAllPeers() public view {
        console2.log("=== Verifying L2-to-L2 Peer Configuration ===");
        verifyChain1Peer();
        verifyChain2Peer();
        console2.log("=== Verification Complete ===");
    }
} 