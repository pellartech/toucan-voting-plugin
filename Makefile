#####################################
# Makefile with Sepolia (Execution)
# and Pegasus (Voting) Deploys
#####################################

# Include .env file (ignore if missing)
-include .env

# For debugging environment variables
check-env:
	echo "PRIVATE_KEY: $(PRIVATE_KEY)"
	echo "API_KEY_INFURA: $(API_KEY_INFURA)"
	echo "ETHERSCAN_API_KEY: $(ETHERSCAN_API_KEY)"
	echo "VOTING_RPC_URL: $(VOTING_RPC_URL)"
	echo "PEGASUS_BLOCKSCOUT_URL: $(PEGASUS_BLOCKSCOUT_URL)"
	echo "PEGASUS_BLOCKSCOUT_API_KEY: $(PEGASUS_BLOCKSCOUT_API_KEY)"
	echo "EXECUTION_RPC_URL: $(EXECUTION_RPC_URL)"

# Linux/macOS convenience for running coverage scripts
allow-scripts:
	chmod +x script/bash/*.sh

# Create an HTML coverage report in ./report (requires lcov & genhtml)
coverage-report:
	./script/bash/coverage-report.sh

# Initial project setup
install:
	make allow-scripts && make coverage-report

##################################
# Example custom cast/forge calls
##################################

send-tokens:
	cast send 0xcD25DAecFe1334e1879580E1762d98E22D7ad50C \
	  "transfer(address,uint256)" 0x8bF1e340055c7dE62F11229A149d3A1918de3d74 100ether \
	  --rpc-url https://optimism-sepolia.infura.io/v3/$(API_KEY_INFURA) \
	  --private-key $(PRIVATE_KEY) 

bridge-tokens:
	forge script BridgeAndSend \
	  --rpc-url https://arbitrum-mainnet.infura.io/v3/$(API_KEY_INFURA) \
	  --private-key $(PRIVATE_KEY) \
	  --broadcast \
	  -vvvvv

unstick-deploy-optimism-sepolia:
	forge script UnstickDeploy \
	  --rpc-url https://optimism-sepolia.infura.io/v3/$(API_KEY_INFURA) \
	  --private-key $(PRIVATE_KEY) \
	  --broadcast \
	  -vvvvv

unstick-dispatch-arbitrum-sepolia:
	forge test --mc ToucanReceiverStuckMessage \
	  --rpc-url https://arbitrum-sepolia.infura.io/v3/$(API_KEY_INFURA) \
	  -vvvvv

test-oapp-conf:
	forge test --mc TestOAppConf \
	  --rpc-url https://arbitrum-mainnet.infura.io/v3/$(API_KEY_INFURA) \
	  -vvvvv

set-send-conf-arbitrum:
	forge script SetOAppConf \
	  --rpc-url https://arbitrum-mainnet.infura.io/v3/$(API_KEY_INFURA) \
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
### Sepolia (using Etherscan for Verification)
###
### If Sepolia is your Execution chain, set (2)=EXECUTION.
###################################################

preview-deploy-sepolia-stage-0:
	$(call deploy-script,0,EXECUTION,${EXECUTION_RPC_URL},)

preview-deploy-sepolia-stage-1:
	$(call deploy-script,1,EXECUTION,${EXECUTION_RPC_URL},)

preview-deploy-sepolia-stage-2:
	$(call deploy-script,2,EXECUTION,${EXECUTION_RPC_URL},)

preview-deploy-sepolia-stage-3:
	$(call deploy-script,3,EXECUTION,${EXECUTION_RPC_URL},)

preview-deploy-sepolia-stage-4:
	$(call deploy-script,4,EXECUTION,${EXECUTION_RPC_URL},)

deploy-sepolia-stage-0:
	$(call deploy-script,0,EXECUTION,${EXECUTION_RPC_URL},--broadcast --ffi --verify --etherscan-api-key $(ETHERSCAN_API_KEY))

deploy-sepolia-stage-1:
	$(call deploy-script,1,EXECUTION,${EXECUTION_RPC_URL},--broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY))

deploy-sepolia-stage-2:
	$(call deploy-script,2,EXECUTION,${EXECUTION_RPC_URL},--broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY))

deploy-sepolia-stage-3:
	$(call deploy-script,3,EXECUTION,${EXECUTION_RPC_URL},--broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY))

deploy-sepolia-stage-4:
	$(call deploy-script,4,EXECUTION,${EXECUTION_RPC_URL},--broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY))


###################################################
### Pegasus (using Blockscout for Verification)
###
### If Pegasus is your Voting chain, set (2)=VOTING.
### Blockscout often doesn't strictly need an API key:
###   --etherscan-api-key $(PEGASUS_BLOCKSCOUT_API_KEY)    (optional)
###################################################

preview-deploy-pegasus-stage-0:
	$(call deploy-script,0,VOTING,$(VOTING_RPC_URL),)

preview-deploy-pegasus-stage-1:
	$(call deploy-script,1,VOTING,$(VOTING_RPC_URL),)

preview-deploy-pegasus-stage-2:
	$(call deploy-script,2,VOTING,$(VOTING_RPC_URL),)

preview-deploy-pegasus-stage-3:
	$(call deploy-script,3,VOTING,$(VOTING_RPC_URL),)

preview-deploy-pegasus-stage-4:
	$(call deploy-script,4,VOTING,$(VOTING_RPC_URL),)

# If your Blockscout instance doesn't require an API key, you can omit it.
# If you do have an API key, append:
#   --etherscan-api-key $(PEGASUS_BLOCKSCOUT_API_KEY)
deploy-pegasus-stage-0:
	$(call deploy-script,0,VOTING,$(VOTING_RPC_URL),--broadcast --legacy --verify --verifier blockscout --verifier-url $(PEGASUS_BLOCKSCOUT_URL)/api)

deploy-pegasus-stage-1:
	$(call deploy-script,1,VOTING,$(VOTING_RPC_URL),--broadcast --legacy --verify --verifier blockscout --verifier-url $(PEGASUS_BLOCKSCOUT_URL)/api)

deploy-pegasus-stage-2:
	$(call deploy-script,2,VOTING,$(VOTING_RPC_URL),--broadcast --legacy --verify --verifier blockscout --verifier-url $(PEGASUS_BLOCKSCOUT_URL)/api)

deploy-pegasus-stage-3:
	$(call deploy-script,3,VOTING,$(VOTING_RPC_URL),--broadcast --legacy --verify --verifier blockscout --verifier-url $(PEGASUS_BLOCKSCOUT_URL)/api)

deploy-pegasus-stage-4:
	$(call deploy-script,4,VOTING,$(VOTING_RPC_URL),--broadcast --legacy --verify --verifier blockscout --verifier-url $(PEGASUS_BLOCKSCOUT_URL)/api)
