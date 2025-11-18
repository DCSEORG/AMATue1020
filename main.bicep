// Azure OpenAI and Cognitive Services Infrastructure
// Using lowest cost development SKUs
// Following Azure best practices for security and cost optimization

@description('Location for all resources')
param location string = 'uksouth'

@description('Unique suffix for resource names')
param uniqueSuffix string = '20251118-102713'

@description('Azure OpenAI SKU - using Standard for development')
param openAiSkuName string = 'S0'

@description('Cognitive Services SKU - using Free tier for development (F0)')
param cognitiveServicesSkuName string = 'F0'

@description('Tags for all resources')
param tags object = {
  Environment: 'Development'
  Project: 'ChatInterface'
  ManagedBy: 'Bicep'
  CreatedDate: '2025-11-18'
}

// Generate unique names for resources
var resourceGroupName = 'rg-chatapp-${uniqueSuffix}'
var openAiName = 'aoai-chatapp-${uniqueSuffix}'
var cognitiveServicesName = 'cs-chatapp-${uniqueSuffix}'

// Azure OpenAI Service
resource openAiAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: openAiName
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: openAiSkuName
  }
  properties: {
    customSubDomainName: openAiName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// Cognitive Services Multi-Service Account (for additional AI capabilities)
resource cognitiveServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: cognitiveServicesName
  location: location
  tags: tags
  kind: 'CognitiveServices'
  sku: {
    name: cognitiveServicesSkuName
  }
  properties: {
    customSubDomainName: cognitiveServicesName
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// Deploy GPT-4o-mini model for chat (cost-effective for development)
resource gpt4oMiniDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAiAccount
  name: 'gpt-4o-mini'
  sku: {
    name: 'Standard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o-mini'
      version: '2024-07-18'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    raiPolicyName: 'Microsoft.Default'
  }
}

// Deploy text-embedding model for semantic search capabilities
resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: openAiAccount
  name: 'text-embedding-ada-002'
  sku: {
    name: 'Standard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-ada-002'
      version: '2'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    raiPolicyName: 'Microsoft.Default'
  }
  dependsOn: [
    gpt4oMiniDeployment
  ]
}

// Outputs for use in application configuration
output openAiEndpoint string = openAiAccount.properties.endpoint
output openAiName string = openAiAccount.name
output openAiId string = openAiAccount.id
output cognitiveServicesEndpoint string = cognitiveServices.properties.endpoint
output cognitiveServicesName string = cognitiveServices.name
output cognitiveServicesId string = cognitiveServices.id
output resourceGroupName string = resourceGroupName
output gpt4oMiniDeploymentName string = gpt4oMiniDeployment.name
output embeddingDeploymentName string = embeddingDeployment.name
