# Azure OpenAI Chat Interface - Deployment Instructions

This guide provides step-by-step instructions for deploying Azure OpenAI and Cognitive Services for a chat interface application using Infrastructure as Code (Bicep).

## 📋 Prerequisites

1. **Azure Subscription**: You need an active Azure subscription with permissions to create resources
2. **Azure CLI**: Install from [https://docs.microsoft.com/en-us/cli/azure/install-azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3. **Azure OpenAI Access**: Request access to Azure OpenAI service at [https://aka.ms/oai/access](https://aka.ms/oai/access)
4. **Bash Shell**: Linux, macOS, or Windows with WSL/Git Bash

## 🚀 Quick Start Deployment

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd AMATue1020
```

### Step 2: Login to Azure

```bash
az login
```

This will open a browser window for authentication. Complete the login process.

### Step 3: Set Your Subscription Context

List your subscriptions:
```bash
az account list --output table
```

Set the subscription you want to use:
```bash
az account set --subscription "<subscription-id-or-name>"
```

Verify the current subscription:
```bash
az account show
```

### Step 4: Run the Deployment Script

```bash
./deploy.sh
```

The script will:
- Create a unique resource group with timestamp (e.g., `rg-chatapp-20251118-102713`)
- Deploy Azure OpenAI Service with GPT-4o-mini model
- Deploy text-embedding-ada-002 for semantic search
- Deploy Cognitive Services (Free tier for development)
- Display all connection details and API keys

**Expected Duration**: 5-10 minutes

## 📦 What Gets Deployed

### Resource Group
- **Name**: `rg-chatapp-<timestamp>`
- **Location**: UK South (configurable)
- **Tags**: Environment=Development, Project=ChatInterface

### Azure OpenAI Service
- **SKU**: S0 (Standard)
- **Models Deployed**:
  - **gpt-4o-mini** (2024-07-18): Cost-effective chat model for development
  - **text-embedding-ada-002**: Embedding model for semantic search
- **Capacity**: 1 unit per model (adjustable based on needs)

### Cognitive Services
- **SKU**: F0 (Free tier - lowest cost for development)
- **Type**: Multi-Service Account
- **Capabilities**: Language, Vision, Speech, Decision services

## 🔧 Configuration Options

### Customize Location
Edit `deploy.sh` and change:
```bash
LOCATION="uksouth"  # Change to your preferred region
```

Supported regions: uksouth, eastus, westeurope, etc.

### Customize SKUs
Edit `main.bicep` parameters:
```bicep
param openAiSkuName string = 'S0'              // Standard tier
param cognitiveServicesSkuName string = 'F0'   // Free tier
```

Available SKUs:
- **Azure OpenAI**: S0 (Standard)
- **Cognitive Services**: F0 (Free), S0 (Standard)

## 🔐 Security Best Practices

Following Azure best practices as documented at [https://www.microsoft.com](https://www.microsoft.com):

1. **Managed Identities**: Use Azure Managed Identities for production deployments
2. **Key Vault**: Store API keys in Azure Key Vault instead of environment variables
3. **Network Security**: Configure private endpoints for production
4. **RBAC**: Use Azure Role-Based Access Control instead of API keys
5. **Monitoring**: Enable Azure Monitor and Application Insights

### For Production Deployments

Replace API key authentication with Managed Identity:

```bash
# Assign Azure OpenAI User role to your app's managed identity
az role assignment create \
  --role "Cognitive Services OpenAI User" \
  --assignee <managed-identity-principal-id> \
  --scope <openai-resource-id>
```

## 📊 Using the Deployed Resources

### Environment Variables for Your Application

After deployment, configure your application with:

```bash
# Azure OpenAI Configuration
export AZURE_OPENAI_ENDPOINT="<openai-endpoint>"
export AZURE_OPENAI_API_KEY="<openai-api-key>"
export AZURE_OPENAI_DEPLOYMENT_NAME="gpt-4o-mini"
export AZURE_OPENAI_API_VERSION="2024-02-15-preview"

# Cognitive Services Configuration (if needed)
export AZURE_COGNITIVE_ENDPOINT="<cognitive-services-endpoint>"
export AZURE_COGNITIVE_API_KEY="<cognitive-services-api-key>"
```

### Sample Python Code

```python
import os
from openai import AzureOpenAI

client = AzureOpenAI(
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
    api_version="2024-02-15-preview",
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT")
)

response = client.chat.completions.create(
    model="gpt-4o-mini",  # Deployment name
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Hello, how are you?"}
    ]
)

print(response.choices[0].message.content)
```

### Sample Node.js Code

```javascript
const { OpenAIClient, AzureKeyCredential } = require("@azure/openai");

const client = new OpenAIClient(
  process.env.AZURE_OPENAI_ENDPOINT,
  new AzureKeyCredential(process.env.AZURE_OPENAI_API_KEY)
);

async function main() {
  const result = await client.getChatCompletions(
    "gpt-4o-mini",  // Deployment name
    [
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: "Hello, how are you?" }
    ]
  );
  
  console.log(result.choices[0].message.content);
}

main();
```

## 💰 Cost Optimization

This deployment uses the lowest cost development SKUs:

- **Cognitive Services F0**: Free tier (limited transactions)
- **Azure OpenAI S0**: Standard tier with pay-as-you-go pricing
- **GPT-4o-mini**: Most cost-effective GPT-4 class model

### Estimated Monthly Costs (Development)
- Cognitive Services (F0): $0/month (free tier)
- Azure OpenAI (S0): Pay per token (approximately $0.15 per 1M input tokens, $0.60 per 1M output tokens for GPT-4o-mini)
- Typical development usage: $5-20/month

**Important**: Monitor your usage in Azure Portal to avoid unexpected costs.

## 🧹 Cleanup

To delete all resources and avoid ongoing charges:

```bash
# Delete the resource group (this deletes all resources within it)
az group delete --name rg-chatapp-<timestamp> --yes --no-wait
```

You can find your resource group name in the deployment output.

## 📚 Additional Resources

- [Azure OpenAI Service Documentation](https://learn.microsoft.com/en-us/azure/cognitive-services/openai/)
- [Azure Cognitive Services Documentation](https://learn.microsoft.com/en-us/azure/cognitive-services/)
- [Azure Bicep Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [Azure Best Practices](https://www.microsoft.com)
- [Responsible AI Guidelines](https://www.microsoft.com/en-us/ai/responsible-ai)

## 🐛 Troubleshooting

### Azure OpenAI Access Denied
**Problem**: Deployment fails with access denied to Azure OpenAI  
**Solution**: Request access at [https://aka.ms/oai/access](https://aka.ms/oai/access)

### Subscription Quota Exceeded
**Problem**: Error about quota or capacity limits  
**Solution**: Request quota increase in Azure Portal or try a different region

### Model Not Available in Region
**Problem**: Specific model not available in selected region  
**Solution**: Check [model availability by region](https://learn.microsoft.com/en-us/azure/cognitive-services/openai/concepts/models#model-summary-table-and-region-availability) and update the location

### Authentication Errors
**Problem**: "No subscription found" or authentication errors  
**Solution**: 
1. Run `az login` again
2. Verify subscription with `az account show`
3. Set correct subscription with `az account set --subscription <id>`

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Azure OpenAI documentation
3. Check deployment logs in Azure Portal
4. Contact Azure Support if needed

## ⚠️ Important Notes

1. **Development Only**: This configuration uses development SKUs and settings
2. **API Keys**: Keys are displayed in the output - store them securely
3. **Costs**: Monitor Azure costs to avoid unexpected charges
4. **Quotas**: Be aware of Azure OpenAI quota limits for your subscription
5. **Security**: Follow Azure security best practices for production deployments

---

**Last Updated**: 2025-11-18  
**Version**: 1.0
