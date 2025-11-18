# Quick Reference - Azure OpenAI Chat Interface

## Resource Group Name
**Format**: `rg-chatapp-YYYYMMDD-HHMMSS`  
**Example**: `rg-chatapp-20251118-102713`

The resource group name is generated automatically with the current timestamp to ensure uniqueness.

## Deployed Resources

### 1. Azure OpenAI Service
- **Name**: `aoai-chatapp-<timestamp>`
- **SKU**: S0 (Standard)
- **Location**: UK South
- **Deployed Models**:
  - `gpt-4o-mini` (2024-07-18) - Chat completions
  - `text-embedding-ada-002` - Text embeddings

### 2. Cognitive Services
- **Name**: `cs-chatapp-<timestamp>`
- **SKU**: F0 (Free tier)
- **Location**: UK South
- **Type**: Multi-Service Account

## Quick Commands

### Deploy
```bash
./deploy.sh
```

### Get Resource Information
```bash
# List all resources in resource group
az resource list --resource-group rg-chatapp-<timestamp> --output table

# Get Azure OpenAI endpoint
az cognitiveservices account show \
  --name aoai-chatapp-<timestamp> \
  --resource-group rg-chatapp-<timestamp> \
  --query properties.endpoint -o tsv

# Get API key
az cognitiveservices account keys list \
  --name aoai-chatapp-<timestamp> \
  --resource-group rg-chatapp-<timestamp> \
  --query key1 -o tsv
```

### Test Deployment
```bash
# Test chat completion
curl -X POST "https://aoai-chatapp-<timestamp>.openai.azure.com/openai/deployments/gpt-4o-mini/chat/completions?api-version=2024-02-15-preview" \
  -H "Content-Type: application/json" \
  -H "api-key: <your-api-key>" \
  -d '{
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

### Cleanup
```bash
# Delete all resources
az group delete --name rg-chatapp-<timestamp> --yes --no-wait
```

## Cost Estimates

### Development Usage (Low Volume)
- **Cognitive Services (F0)**: $0/month (Free tier)
- **Azure OpenAI**: ~$5-20/month
  - GPT-4o-mini: $0.15/1M input tokens, $0.60/1M output tokens
  - Embeddings: $0.10/1M tokens

### Typical Monthly Costs by Usage
- **Light** (100K tokens/day): ~$5/month
- **Medium** (500K tokens/day): ~$20/month
- **Heavy** (2M tokens/day): ~$80/month

## Azure Best Practices Applied

✅ **Infrastructure as Code**: Using Bicep for reproducible deployments  
✅ **Cost Optimization**: Lowest cost development SKUs  
✅ **Naming Conventions**: Consistent Azure naming standards  
✅ **Tagging Strategy**: Environment, Project, ManagedBy tags  
✅ **Security**: API key rotation capabilities  
✅ **Monitoring Ready**: Azure Monitor integration available  

## Next Steps for Production

1. **Security Enhancements**:
   - Enable Managed Identity
   - Configure Private Endpoints
   - Store keys in Azure Key Vault
   - Enable Azure AD authentication

2. **Networking**:
   - Configure Virtual Network integration
   - Set up Private Link
   - Configure NSG rules

3. **Monitoring**:
   - Enable Application Insights
   - Set up Azure Monitor alerts
   - Configure diagnostic settings
   - Create dashboards

4. **Governance**:
   - Implement Azure Policy
   - Enable resource locks
   - Configure RBAC
   - Set up Azure Blueprints

5. **High Availability**:
   - Multi-region deployment
   - Implement load balancing
   - Configure automatic failover
   - Set up geo-redundancy

## Support & Resources

- **Documentation**: See DEPLOYMENT_INSTRUCTIONS.md
- **Azure OpenAI Docs**: https://learn.microsoft.com/en-us/azure/cognitive-services/openai/
- **Azure Best Practices**: https://www.microsoft.com
- **Bicep Reference**: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/

---

**Created**: 2025-11-18  
**Purpose**: Development and POC deployments  
**Maintenance**: Update SKUs and models as Azure offerings evolve
