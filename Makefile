# Environment variables
PRIVATE_KEY ?= $(shell cat .env | grep PRIVATE_KEY | cut -d '=' -f2)
CHAIN_1_RPC_URL ?= $(shell cat .env | grep CHAIN_1_RPC_URL | cut -d '=' -f2)
CHAIN_2_RPC_URL ?= $(shell cat .env | grep CHAIN_2_RPC_URL | cut -d '=' -f2)

# Check if environment variables are set
check-env:
	@echo "Checking environment variables..."
	@if [ -z "$(PRIVATE_KEY)" ]; then echo "ERROR: PRIVATE_KEY not set in .env"; exit 1; fi
	@if [ -z "$(CHAIN_1_RPC_URL)" ]; then echo "ERROR: CHAIN_1_RPC_URL not set in .env"; exit 1; fi
	@if [ -z "$(CHAIN_2_RPC_URL)" ]; then echo "ERROR: CHAIN_2_RPC_URL not set in .env"; exit 1; fi
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
		--rpc-url $(CHAIN_1_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		-vvvvv

# Bridge tokens (legacy)
bridge-tokens:
	@echo "Bridging tokens..."
	forge script script/BridgeAndSend.s.sol \
		--rpc-url $(CHAIN_2_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		-vvvvv

# Unstick message on Optimism execution chain
unstick-deploy-optimism-execution:
	@echo "Unsticking message on Optimism execution chain..."
	forge script script/UnstickMessage.s.sol \
		--sig "unstickDeployOptimismExecution()" \
		--rpc-url $(CHAIN_2_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		-vvvvv

# Unstick dispatch on Arbitrum execution chain
unstick-dispatch-arbitrum-execution:
	@echo "Unsticking dispatch on Arbitrum execution chain..."
	forge script script/UnstickMessage.s.sol \
		--sig "unstickDispatchArbitrumExecution()" \
		--rpc-url $(CHAIN_1_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		-vvvvv

# Test OApp configuration
test-oapp-conf:
	@echo "Testing OApp configuration..."
	forge script script/BridgeAndSend.s.sol \
		--sig "testOAppConf()" \
		--rpc-url $(CHAIN_1_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		-vvvvv

# Set send configuration for Arbitrum
set-send-conf-arbitrum:
	@echo "Setting send configuration for Arbitrum..."
	forge script script/BridgeAndSend.s.sol \
		--sig "setSendConfArbitrum()" \
		--rpc-url $(CHAIN_1_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		-vvvvv

# =============================================================================
# DEPLOYMENT TARGETS
# =============================================================================

# Preview deployment stages for execution chain
preview-deploy-execution-stage-0:
	@echo "Previewing execution chain deployment stage 0..."
	forge script script/DeployV2.s.sol --sig "previewDeployExecutionStage0()" --rpc-url $(CHAIN_1_RPC_URL) --private-key $(PRIVATE_KEY) -vvvvv

preview-deploy-execution-stage-1:
	@echo "Previewing execution chain deployment stage 1..."
	forge script script/DeployV2.s.sol --sig "previewDeployExecutionStage1()" --rpc-url $(CHAIN_1_RPC_URL) --private-key $(PRIVATE_KEY) -vvvvv

preview-deploy-execution-stage-2:
	@echo "Previewing execution chain deployment stage 2..."
	forge script script/DeployV2.s.sol --sig "previewDeployExecutionStage2()" --rpc-url $(CHAIN_1_RPC_URL) --private-key $(PRIVATE_KEY) -vvvvv

preview-deploy-execution-stage-3:
	@echo "Previewing execution chain deployment stage 3..."
	forge script script/DeployV2.s.sol --sig "previewDeployExecutionStage3()" --rpc-url $(CHAIN_1_RPC_URL) --private-key $(PRIVATE_KEY) -vvvvv

preview-deploy-execution-stage-4:
	@echo "Previewing execution chain deployment stage 4..."
	forge script script/DeployV2.s.sol --sig "previewDeployExecutionStage4()" --rpc-url $(CHAIN_1_RPC_URL) --private-key $(PRIVATE_KEY) -vvvvv

# Deploy execution chain stages
deploy-execution-stage-0:
	@echo "Deploying execution chain stage 0..."
	forge script script/DeployV2.s.sol --sig "deployExecutionStage0()" --rpc-url $(CHAIN_1_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --legacy --gas-price 1000000000 -vvvvv

deploy-execution-stage-1:
	@echo "Deploying execution chain stage 1..."
	forge script script/DeployV2.s.sol --sig "deployExecutionStage1()" --rpc-url $(CHAIN_1_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --legacy --gas-price 1000000000 -vvvvv

deploy-execution-stage-2:
	@echo "Deploying execution chain stage 2..."
	forge script script/DeployV2.s.sol --sig "deployExecutionStage2()" --rpc-url $(CHAIN_1_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --legacy --gas-price 1000000000 -vvvvv

deploy-execution-stage-3:
	@echo "Deploying execution chain stage 3..."
	forge script script/DeployV2.s.sol --sig "deployExecutionStage3()" --rpc-url $(CHAIN_1_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --legacy --gas-price 1000000000 -vvvvv

deploy-execution-stage-4:
	@echo "Deploying execution chain stage 4..."
	forge script script/DeployV2.s.sol --sig "deployExecutionStage4()" --rpc-url $(CHAIN_1_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --legacy --gas-price 1000000000 -vvvvv

# Preview deployment stages for voting chain
preview-deploy-voting-stage-0:
	@echo "Previewing voting chain deployment stage 0..."
	forge script script/DeployV2.s.sol --sig "previewDeployVotingStage0()" --rpc-url $(CHAIN_2_RPC_URL) --private-key $(PRIVATE_KEY) -vvvvv

preview-deploy-voting-stage-1:
	@echo "Previewing voting chain deployment stage 1..."
	forge script script/DeployV2.s.sol --sig "previewDeployVotingStage1()" --rpc-url $(CHAIN_2_RPC_URL) --private-key $(PRIVATE_KEY) -vvvvv

preview-deploy-voting-stage-2:
	@echo "Previewing voting chain deployment stage 2..."
	forge script script/DeployV2.s.sol --sig "previewDeployVotingStage2()" --rpc-url $(CHAIN_2_RPC_URL) --private-key $(PRIVATE_KEY) -vvvvv

preview-deploy-voting-stage-3:
	@echo "Previewing voting chain deployment stage 3..."
	forge script script/DeployV2.s.sol --sig "previewDeployVotingStage3()" --rpc-url $(CHAIN_2_RPC_URL) --private-key $(PRIVATE_KEY) -vvvvv

preview-deploy-voting-stage-4:
	@echo "Previewing voting chain deployment stage 4..."
	forge script script/DeployV2.s.sol --sig "previewDeployVotingStage4()" --rpc-url $(CHAIN_2_RPC_URL) --private-key $(PRIVATE_KEY) -vvvvv

# Deploy voting chain stages
deploy-voting-stage-0:
	@echo "Deploying voting chain stage 0..."
	forge script script/DeployV2.s.sol --sig "deployVotingStage0()" --rpc-url $(CHAIN_2_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --legacy --gas-price 1000000000 -vvvvv

deploy-voting-stage-1:
	@echo "Deploying voting chain stage 1..."
	forge script script/DeployV2.s.sol --sig "deployVotingStage1()" --rpc-url $(CHAIN_2_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --legacy --gas-price 1000000000 -vvvvv

deploy-voting-stage-2:
	@echo "Deploying voting chain stage 2..."
	forge script script/DeployV2.s.sol --sig "deployVotingStage2()" --rpc-url $(CHAIN_2_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --legacy --gas-price 1000000000 -vvvvv

deploy-voting-stage-3:
	@echo "Deploying voting chain stage 3..."
	forge script script/DeployV2.s.sol --sig "deployVotingStage3()" --rpc-url $(CHAIN_2_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --legacy --gas-price 1000000000 -vvvvv

deploy-voting-stage-4:
	@echo "Deploying voting chain stage 4..."
	forge script script/DeployV2.s.sol --sig "deployVotingStage4()" --rpc-url $(CHAIN_2_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --legacy --gas-price 1000000000 -vvvvv

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
