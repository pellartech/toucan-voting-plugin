# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# # Environment variables
# PRIVATE_KEY ?= $(shell cat .env | grep PRIVATE_KEY | cut -d '=' -f2)
# EXECUTION_RPC_URL ?= $(shell cat .env | grep EXECUTION_RPC_URL | cut -d '=' -f2)
# VOTING_RPC_URL ?= $(shell cat .env | grep VOTING_RPC_URL | cut -d '=' -f2)

# # Verifier configuration (set in .env)
# # EXEC_VERIFIER/VOTING_VERIFIER: one of 'etherscan' or 'blockscout'
# # If 'blockscout', also set EXEC_BLOCKSCOUT_URL / VOTING_BLOCKSCOUT_URL (without trailing /api)
# EXEC_VERIFIER ?= $(shell cat .env | grep EXEC_VERIFIER | cut -d '=' -f2)
# VOTING_VERIFIER ?= $(shell cat .env | grep VOTING_VERIFIER | cut -d '=' -f2)
# EXEC_BLOCKSCOUT_URL ?= $(shell cat .env | grep EXEC_BLOCKSCOUT_URL | cut -d '=' -f2)
# VOTING_BLOCKSCOUT_URL ?= $(shell cat .env | grep VOTING_BLOCKSCOUT_URL | cut -d '=' -f2)

# Compute verification flags per chain
VERIFY_FLAGS_EXEC := $(if $(filter $(EXEC_VERIFIER),blockscout),--verify --verifier blockscout --verifier-url $(EXEC_BLOCKSCOUT_URL)/api,$(if $(filter $(EXEC_VERIFIER),etherscan),--verify,))
VERIFY_FLAGS_VOTING := $(if $(filter $(VOTING_VERIFIER),blockscout),--verify --verifier blockscout --verifier-url $(VOTING_BLOCKSCOUT_URL)/api,$(if $(filter $(VOTING_VERIFIER),etherscan),--verify,))

# Check if environment variables are set
check-env:
	@echo "Checking environment variables..."
	@if [ -z "$(PRIVATE_KEY)" ]; then echo "ERROR: PRIVATE_KEY not set in .env"; exit 1; fi
	@if [ -z "$(EXECUTION_RPC_URL)" ]; then echo "ERROR: EXECUTION_RPC_URL not set in .env"; exit 1; fi
	@if [ -z "$(VOTING_RPC_URL)" ]; then echo "ERROR: VOTING_RPC_URL not set in .env"; exit 1; fi
	@echo "Environment variables are properly set"

# Allow scripts to be executed
allow-scripts:
	@chmod +x script/bash/*.sh

# Generate coverage report
coverage-report:
	@echo "Generating coverage report..."
	@script/bash/coverage-report.sh

# Install dependencies
install:
	@echo "Installing dependencies..."
	forge install
	@echo "Dependencies installed successfully"

# Send tokens (legacy)
send-tokens:
	@echo "Sending tokens..."
	forge script script/BridgeAndSend.s.sol \
		--rpc-url $(EXECUTION_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		-vvvvv

# Bridge tokens (legacy)
bridge-tokens:
	@echo "Bridging tokens..."
	forge script script/BridgeAndSend.s.sol \
		--rpc-url $(VOTING_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		-vvvvv

# Unstick message on Optimism execution chain
unstick-deploy-optimism-execution:
	@echo "Unsticking message on Optimism execution chain..."
	forge script script/UnstickMessage.s.sol \
		--sig "unstickDeployOptimismExecution()" \
		--rpc-url $(VOTING_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		-vvvvv

# Unstick dispatch on Arbitrum execution chain
unstick-dispatch-arbitrum-execution:
	@echo "Unsticking dispatch on Arbitrum execution chain..."
	forge script script/UnstickMessage.s.sol \
		--sig "unstickDispatchArbitrumExecution()" \
		--rpc-url $(EXECUTION_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		-vvvvv

# Test OApp configuration
test-oapp-conf:
	@echo "Testing OApp configuration..."
	forge script script/BridgeAndSend.s.sol \
		--sig "testOAppConf()" \
		--rpc-url $(EXECUTION_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		-vvvvv

# Set send configuration for Arbitrum
set-send-conf-arbitrum:
	@echo "Setting send configuration for Arbitrum..."
	forge script script/BridgeAndSend.s.sol \
		--sig "setSendConfArbitrum()" \
		--rpc-url $(EXECUTION_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		-vvvvv

##################################
# Deploy Script Helper
##################################
define deploy-script
	export STAGE=$(1) && \
	export EXECUTION_OR_VOTING=$(2) && \
	forge script DeployE2E \
		--rpc-url $(3) \
		--private-key $(PRIVATE_KEY) \
		$(4) \
		-vvvvv
endef

###################################################
### execution (using Etherscan for Verification)
###
### If execution is your Execution chain, set (2)=EXECUTION.
###################################################

preview-deploy-execution-stage-0:
	$(call deploy-script,0,EXECUTION,$(EXECUTION_RPC_URL),)

preview-deploy-execution-stage-1:
	$(call deploy-script,1,EXECUTION,$(EXECUTION_RPC_URL),)

preview-deploy-execution-stage-2:
	$(call deploy-script,2,EXECUTION,$(EXECUTION_RPC_URL),)

preview-deploy-execution-stage-3:
	$(call deploy-script,3,EXECUTION,$(EXECUTION_RPC_URL),)

preview-deploy-execution-stage-4:
	$(call deploy-script,4,EXECUTION,$(EXECUTION_RPC_URL),)

preview-deploy-execution-stage-5:
	$(call deploy-script,5,EXECUTION,$(EXECUTION_RPC_URL),)

deploy-execution-stage-0:
	$(call deploy-script,0,EXECUTION,$(EXECUTION_RPC_URL),--broadcast --ffi $(VERIFY_FLAGS_EXEC))

deploy-execution-stage-1:
	$(call deploy-script,1,EXECUTION,$(EXECUTION_RPC_URL),--broadcast $(VERIFY_FLAGS_EXEC))

deploy-execution-stage-2:
	$(call deploy-script,2,EXECUTION,$(EXECUTION_RPC_URL),--broadcast $(VERIFY_FLAGS_EXEC))

deploy-execution-stage-3:
	$(call deploy-script,3,EXECUTION,$(EXECUTION_RPC_URL),--broadcast $(VERIFY_FLAGS_EXEC))

deploy-execution-stage-4:
	$(call deploy-script,4,EXECUTION,${EXECUTION_RPC_URL},--broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY))

deploy-execution-stage-5:
	$(call deploy-script,5,EXECUTION,$(EXECUTION_RPC_URL),--broadcast $(VERIFY_FLAGS_EXEC))

###################################################
### voting (using Blockscout for Verification)
###
### If voting is your Voting chain, set (2)=VOTING.
### Blockscout often doesn't strictly need an API key:
###   --etherscan-api-key $(voting_BLOCKSCOUT_API_KEY)    (optional)
###################################################

preview-deploy-voting-stage-0:
	$(call deploy-script,0,VOTING,$(VOTING_RPC_URL),)

preview-deploy-voting-stage-1:
	$(call deploy-script,1,VOTING,$(VOTING_RPC_URL),)

preview-deploy-voting-stage-2:
	$(call deploy-script,2,VOTING,$(VOTING_RPC_URL),)

preview-deploy-voting-stage-3:
	$(call deploy-script,3,VOTING,$(VOTING_RPC_URL),)

preview-deploy-voting-stage-4:
	$(call deploy-script,4,VOTING,$(VOTING_RPC_URL),)

# If your Blockscout instance doesn't require an API key, you can omit it.
# If you do have an API key, append:
#   --etherscan-api-key $(voting_BLOCKSCOUT_API_KEY)
deploy-voting-stage-0:
	$(call deploy-script,0,VOTING,$(VOTING_RPC_URL),--broadcast --legacy $(VERIFY_FLAGS_VOTING))

deploy-voting-stage-1:
	$(call deploy-script,1,VOTING,$(VOTING_RPC_URL),--broadcast --legacy $(VERIFY_FLAGS_VOTING))

deploy-voting-stage-2:
	$(call deploy-script,2,VOTING,$(VOTING_RPC_URL),--broadcast --legacy $(VERIFY_FLAGS_VOTING))

deploy-voting-stage-3:
	$(call deploy-script,3,VOTING,$(VOTING_RPC_URL),--broadcast --legacy $(VERIFY_FLAGS_VOTING))

deploy-voting-stage-4:
	$(call deploy-script,4,VOTING,$(VOTING_RPC_URL),--broadcast --legacy $(VERIFY_FLAGS_VOTING))

# =============================================================================
# L2-TO-L2 SETUP AND TRANSFER TARGETS
# =============================================================================

# Setup L2-to-L2 peer relationships (separate runs per chain)
setup-l2-to-l2-peers-chain1-to-chain2:
	@echo "Setting Chain 1 bridge peer to Chain 2..."
	PEER_DIRECTION=0 forge script script/SetL2ToL2Peers.s.sol \
		--rpc-url $(CHAIN_1_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--legacy \
		--gas-price 1000000000 \
		-vvvvv

setup-l2-to-l2-peers-chain2-to-chain1:
	@echo "Setting Chain 2 bridge peer to Chain 1..."
	PEER_DIRECTION=1 forge script script/SetL2ToL2Peers.s.sol \
		--rpc-url $(CHAIN_2_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--legacy \
		--gas-price 1000000000 \
		-vvvvv

# Composite target to run both directions
setup-l2-to-l2-peers: setup-l2-to-l2-peers-chain1-to-chain2 setup-l2-to-l2-peers-chain2-to-chain1
	@echo "L2-to-L2 peer setup (both directions) complete"

# Verify L2-to-L2 peer configuration (per chain) and composite
verify-l2-to-l2-peers-chain1:
	@echo "Verifying Chain 1 peer configuration..."
	forge script script/SetL2ToL2Peers.s.sol \
		--sig "verifyChain1Peer()" \
		--rpc-url $(CHAIN_1_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		-vvvvv

verify-l2-to-l2-peers-chain2:
	@echo "Verifying Chain 2 peer configuration..."
	forge script script/SetL2ToL2Peers.s.sol \
		--sig "verifyChain2Peer()" \
		--rpc-url $(CHAIN_2_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		-vvvvv

verify-l2-to-l2-peers: verify-l2-to-l2-peers-chain1 verify-l2-to-l2-peers-chain2
	@echo "Verified L2-to-L2 peers on both chains"

# Transfer tokens from Chain 1 to Chain 2
transfer-chain1-to-chain2:
	@echo "Transferring tokens from Chain 1 to Chain 2..."
	@forge script script/SimpleTransfer.s.sol \
		--rpc-url $(CHAIN_1_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--legacy \
		--gas-price 1000000000 \
		-vvvvv

# Transfer tokens from Chain 2 to Chain 1
transfer-chain2-to-chain1:
	@echo "Transferring tokens from Chain 2 to Chain 1..."
	@forge script script/ReverseTransfer.s.sol \
		--rpc-url $(CHAIN_2_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--legacy \
		--gas-price 1000000000 \
		-vvvvv

# Check token balances on Chain 1
check-l2-balances-chain-1:
	@echo "Checking token balances on Chain 1..."
	@forge script script/SimpleTransfer.s.sol \
		--sig "checkChain1Balance()" \
		--rpc-url $(CHAIN_1_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		-vvvvv

# Check token balances on Chain 2
check-l2-balances-chain-2:
	@echo "Checking token balances on Chain 2..."
	@forge script script/ReverseTransfer.s.sol \
		--sig "checkChain2Balance()" \
		--rpc-url $(CHAIN_2_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		-vvvvv

# Check both chain balances
check-l2-balances: check-l2-balances-chain-1 check-l2-balances-chain-2
	@echo "Checked balances on both chains"

# Complete L2-to-L2 setup and test
setup-and-test-l2-to-l2: setup-l2-to-l2-peers verify-l2-to-l2-peers check-l2-balances
	@echo "L2-to-L2 setup and test completed"

# Grant OApp permissions
grant-oapp-permissions:
	@echo "Granting OApp permissions..."
	forge script script/SetL2ToL2Peers.s.sol \
		--sig "grantOAppPermissions()" \
		--rpc-url $(CHAIN_1_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--legacy \
		--gas-price 1000000000 \
		-vvvvv
