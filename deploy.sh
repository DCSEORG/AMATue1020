#!/bin/bash

# Deploy Azure OpenAI and Cognitive Services for Chat Interface App
# This script creates all necessary Azure resources using Bicep
# Following Azure best practices for development environments

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Azure OpenAI Chat Interface Deployment Script          ║${NC}"
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""

# Configuration
LOCATION="uksouth"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
RESOURCE_GROUP="rg-chatapp-${TIMESTAMP}"
DEPLOYMENT_NAME="chatapp-deployment-${TIMESTAMP}"

echo -e "${YELLOW}Configuration:${NC}"
echo "  Location: $LOCATION"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Deployment Name: $DEPLOYMENT_NAME"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Error: Azure CLI is not installed${NC}"
    echo "Please install Azure CLI from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Check if user is logged in
echo -e "${YELLOW}Checking Azure login status...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${RED}Error: Not logged in to Azure${NC}"
    echo "Please run: az login"
    exit 1
fi

# Show current subscription
SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo -e "${GREEN}✓ Logged in to Azure${NC}"
echo "  Subscription: $SUBSCRIPTION_NAME"
echo "  Subscription ID: $SUBSCRIPTION_ID"
echo ""

# Confirm deployment
read -p "Do you want to proceed with deployment? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled${NC}"
    exit 0
fi

# Create Resource Group
echo -e "${YELLOW}Creating Resource Group...${NC}"
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags Environment=Development Project=ChatInterface ManagedBy=Bicep CreatedDate=$(date +"%Y-%m-%d")

echo -e "${GREEN}✓ Resource Group created${NC}"
echo ""

# Deploy Bicep template
echo -e "${YELLOW}Deploying Azure OpenAI and Cognitive Services...${NC}"
echo "This may take 5-10 minutes..."
echo ""

az deployment group create \
    --name "$DEPLOYMENT_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --template-file main.bicep \
    --parameters location="$LOCATION" uniqueSuffix="$TIMESTAMP" \
    --verbose

echo -e "${GREEN}✓ Deployment completed successfully${NC}"
echo ""

# Get outputs
echo -e "${YELLOW}Retrieving deployment outputs...${NC}"
OPENAI_ENDPOINT=$(az deployment group show --name "$DEPLOYMENT_NAME" --resource-group "$RESOURCE_GROUP" --query properties.outputs.openAiEndpoint.value -o tsv)
OPENAI_NAME=$(az deployment group show --name "$DEPLOYMENT_NAME" --resource-group "$RESOURCE_GROUP" --query properties.outputs.openAiName.value -o tsv)
CS_ENDPOINT=$(az deployment group show --name "$DEPLOYMENT_NAME" --resource-group "$RESOURCE_GROUP" --query properties.outputs.cognitiveServicesEndpoint.value -o tsv)
CS_NAME=$(az deployment group show --name "$DEPLOYMENT_NAME" --resource-group "$RESOURCE_GROUP" --query properties.outputs.cognitiveServicesName.value -o tsv)
GPT_DEPLOYMENT=$(az deployment group show --name "$DEPLOYMENT_NAME" --resource-group "$RESOURCE_GROUP" --query properties.outputs.gpt4oMiniDeploymentName.value -o tsv)
EMBEDDING_DEPLOYMENT=$(az deployment group show --name "$DEPLOYMENT_NAME" --resource-group "$RESOURCE_GROUP" --query properties.outputs.embeddingDeploymentName.value -o tsv)

# Get API Keys (for development environments)
OPENAI_KEY=$(az cognitiveservices account keys list --name "$OPENAI_NAME" --resource-group "$RESOURCE_GROUP" --query key1 -o tsv)
CS_KEY=$(az cognitiveservices account keys list --name "$CS_NAME" --resource-group "$RESOURCE_GROUP" --query key1 -o tsv)

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Deployment Summary                            ║${NC}"
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""
echo -e "${GREEN}Resource Group:${NC} $RESOURCE_GROUP"
echo ""
echo -e "${GREEN}Azure OpenAI Service:${NC}"
echo "  Name: $OPENAI_NAME"
echo "  Endpoint: $OPENAI_ENDPOINT"
echo "  GPT-4o-mini Deployment: $GPT_DEPLOYMENT"
echo "  Embedding Deployment: $EMBEDDING_DEPLOYMENT"
echo "  API Key: $OPENAI_KEY"
echo ""
echo -e "${GREEN}Cognitive Services:${NC}"
echo "  Name: $CS_NAME"
echo "  Endpoint: $CS_ENDPOINT"
echo "  API Key: $CS_KEY"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Configure your application with the endpoints and keys above"
echo "2. Use GPT-4o-mini deployment for chat completions"
echo "3. Use text-embedding-ada-002 for semantic search"
echo "4. Review Azure best practices: https://www.microsoft.com"
echo ""
echo -e "${YELLOW}To delete all resources when done:${NC}"
echo "  az group delete --name $RESOURCE_GROUP --yes --no-wait"
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Deployment Complete! 🎉                       ║${NC}"
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
