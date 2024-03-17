targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@maxLength(5)
param randomString string

@minLength(1)
@description('Primary location for all resources')
param location string

param aadWebClientId string = ''
param aadMgmtClientId string = ''
param aadMgmtUrl string = ''
@secure()
param aadMgmtClientSecret string = ''
param aadMgmtServicePrincipalId string = ''
param buildNumber string = 'local'
param isInAutomation bool = false
param useExistingAOAIService bool
param azureOpenAIServiceName string
param azureOpenAIResourceGroup string
@secure()
param azureOpenAIServiceKey string
param openAiServiceName string = ''
param openAiSkuName string = 'S0'
param cosmosdbName string = ''
param formRecognizerName string = ''
param enrichmentName string = ''
param formRecognizerSkuName string = 'S0'
param enrichmentSkuName string = 'S0'
param appServicePlanName string = ''
param enrichmentAppServicePlanName string = ''
param resourceGroupName string = ''
param logAnalyticsName string = ''
param applicationInsightsName string = ''
param backendServiceName string = ''
param enrichmentServiceName string = ''
param functionsAppName string = ''
param searchServicesName string = ''
param searchServicesSkuName string = 'standard'
param storageAccountName string = ''
param containerName string = 'content'
param uploadContainerName string = 'upload'
param functionLogsContainerName string = 'logs'
param searchIndexName string = 'vector-index'
param chatGptDeploymentName string = 'gpt-35-turbo-16k'
param azureOpenAIEmbeddingDeploymentName string = 'text-embedding-ada-002'
param azureOpenAIEmbeddingsModelName string = 'text-embedding-ada-002'
param azureOpenAIEmbeddingsModelVersion string = '2'
param useAzureOpenAIEmbeddings bool = true
param sentenceTransformersModelName string = 'BAAI/bge-small-en-v1.5'
param sentenceTransformerEmbeddingVectorSize string = '384'
param embeddingsDeploymentCapacity int = 240
param chatWarningBannerText string = ''
param chatGptModelName string = 'gpt-35-turbo-16k'
param chatGptModelVersion string = '0613'
param chatGptDeploymentCapacity int = 240
// metadata in our chunking strategy adds about 180-200 tokens to the size of the chunks, 
// our default target size is 750 tokens so the chunk files that get indexed will be around 950 tokens each
param chunkTargetSize string = '750'
param targetPages string = 'ALL'
param formRecognizerApiVersion string = '2023-07-31'
param queryTermLanguage string = 'English'
param isGovCloudDeployment bool = contains(location, 'usgov')

// This block of variables are used by the enrichment pipeline
// Azure Functions or Container. These values are also populated
// in the debug env files at 'functions/local.settings.json'. You
// may want to update the local debug values separate from what is deployed to Azure.
param maxSecondsHideOnUpload string = '300'
param maxSubmitRequeueCount string = '10'
param pollQueueSubmitBackoff string = '60'
param pdfSubmitQueueBackoff string = '60'
param maxPollingRequeueCount string = '10'
param submitRequeueHideSeconds string = '1200'
param pollingBackoff string = '30'
param maxReadAttempts string = '5'
param maxEnrichmentRequeueCount string = '10'
param enrichmentBackoff string = '60'
param targetTranslationLanguage string = 'en'

// End of valued replicated in debug env files

// This block of variables are used for Branding
param applicationtitle string = ''
// End branding

param enableDevCode bool = false
param tenantId string = ''
param subscriptionId string = ''

@description('Id of the user or app to assign application roles')
param principalId string = ''
param kvAccessObjectId string = ''

var abbrs = loadJsonContent('abbreviations.json')
var prefix = 'infoasst'


// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan 'core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: rg
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${prefix}-${abbrs.webServerFarms}${randomString}'
    location: location
    tags: tags
    sku: {
      name: 'S1'
      capacity: 3
    }
    kind: 'linux'
  }
}

// Create an App Service Plan for functions
module funcServicePlan 'core/host/funcserviceplan.bicep' = {
  name: 'funcserviceplan'
  scope: rg
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${prefix}-${abbrs.funcServerFarms}${randomString}'
    location: location
    tags: tags
    sku: {
      name: 'S2'
      capacity: 2
    }
    kind: 'linux'
  }
}

// Create an App Service Plan to group applications under the same payment plan and SKU
module enrichmentAppServicePlan 'core/host/enrichmentappserviceplan.bicep' = {
  name: 'enrichmentAppserviceplan'
  scope: rg
  params: {
    name: !empty(enrichmentAppServicePlanName) ? enrichmentAppServicePlanName : '${prefix}-enrichment${abbrs.webServerFarms}${randomString}'
    location: location
    tags: tags
    sku: {
      name: 'P1v3'
      tier: 'PremiumV3'
      size: 'P1v3'
      family: 'Pv3'
      capacity: 1
    }
    kind: 'linux'
    reserved: true
  }
}

module cognitiveServices 'core/ai/cognitiveservices.bicep' = if (!useExistingAOAIService) {
  name: 'openai'
  scope: rg
  params: {
    name: !empty(openAiServiceName) ? openAiServiceName : '${prefix}-${abbrs.openAIServices}${randomString}'
    location: location
    tags: tags
    keyVaultName: kvModule.outputs.keyVaultName
    sku: {
      name: openAiSkuName
    }
    deployments: [
      {
        name: !empty(chatGptDeploymentName) ? chatGptDeploymentName : !empty(chatGptModelName) ? chatGptModelName : 'gpt-35-turbo-16k'
        model: {
          format: 'OpenAI'
          name: !empty(chatGptModelName) ? chatGptModelName : 'gpt-35-turbo-16k'
          version: !empty(chatGptModelVersion) ? chatGptModelVersion : '0613'
        }
        sku: {
          name: 'Standard'
          capacity: chatGptDeploymentCapacity
        }
        raiPolicyName: 'Microsoft.Default'
      }
      {
        name: !empty(azureOpenAIEmbeddingDeploymentName) ? azureOpenAIEmbeddingDeploymentName : azureOpenAIEmbeddingDeploymentName
        model: {
          format: 'OpenAI'
          name: !empty(azureOpenAIEmbeddingDeploymentName) ? azureOpenAIEmbeddingDeploymentName : 'text-embedding-ada-002'
          version: '2'
        }
        sku: {
          name: 'Standard'
          capacity: embeddingsDeploymentCapacity
        }
        raiPolicyName: 'Microsoft.Default'
      }
    ]
  }
}

module formrecognizer 'core/ai/formrecognizer.bicep' = {
  scope: rg
  name: 'formrecognizer'
  params: {
    name: !empty(formRecognizerName) ? formRecognizerName : '${prefix}-${abbrs.formRecognizer}${randomString}'
    location: location
    tags: tags
    sku: {
      name: formRecognizerSkuName
    }
    isGovCloudDeployment: isGovCloudDeployment
    keyVaultName: kvModule.outputs.keyVaultName
  }
}

module enrichment 'core/ai/enrichment.bicep' = {
  scope: rg
  name: 'enrichment'
  params: {
    name: !empty(enrichmentName) ? enrichmentName : '${prefix}-enrichment-${abbrs.cognitiveServicesAccounts}${randomString}'
    location: location
    tags: tags
    sku: enrichmentSkuName
    isGovCloudDeployment: isGovCloudDeployment
    keyVaultName: kvModule.outputs.keyVaultName
  }
}

module searchServices 'core/search/search-services.bicep' = {
  scope: rg
  name: 'search-services'
  params: {
    name: !empty(searchServicesName) ? searchServicesName : '${prefix}-${abbrs.searchSearchServices}${randomString}'
    keyVaultName: kvModule.outputs.keyVaultName
    location: location
    tags: tags
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
    sku: {
      name: searchServicesSkuName
    }
    semanticSearch: 'free'
    isGovCloudDeployment: isGovCloudDeployment
  }
}

// Function App 
module functions 'core/function/function.bicep' = {
  name: 'functions'
  scope: rg
  params: {
    name: !empty(functionsAppName) ? functionsAppName : '${prefix}-${abbrs.webSitesFunctions}${randomString}'
    location: location
    tags: tags
    appServicePlanId: funcServicePlan.outputs.id
    runtime: 'python'
    keyVaultName: kvModule.outputs.keyVaultName
    appInsightsConnectionString: logging.outputs.applicationInsightsConnectionString
    appInsightsInstrumentationKey: logging.outputs.applicationInsightsInstrumentationKey
    blobStorageAccountName: storage.outputs.name
    blobStorageAccountEndpoint: storage.outputs.primaryEndpoints.blob
    blobStorageAccountOutputContainerName: containerName
    blobStorageAccountUploadContainerName: uploadContainerName
    blobStorageAccountLogContainerName: functionLogsContainerName
    formRecognizerEndpoint: formrecognizer.outputs.formRecognizerAccountEndpoint
    CosmosDBEndpointURL: cosmosdb.outputs.CosmosDBEndpointURL
    CosmosDBLogDatabaseName: cosmosdb.outputs.CosmosDBLogDatabaseName
    CosmosDBLogContainerName: cosmosdb.outputs.CosmosDBLogContainerName
    CosmosDBTagsDatabaseName: cosmosdb.outputs.CosmosDBTagsDatabaseName
    CosmosDBTagsContainerName: cosmosdb.outputs.CosmosDBTagsContainerName
    chunkTargetSize: chunkTargetSize
    targetPages: targetPages
    formRecognizerApiVersion: formRecognizerApiVersion
    pdfSubmitQueue: pdfSubmitQueue
    pdfPollingQueue: pdfPollingQueue
    nonPdfSubmitQueue: nonPdfSubmitQueue
    mediaSubmitQueue: mediaSubmitQueue
    maxSecondsHideOnUpload: maxSecondsHideOnUpload
    maxSubmitRequeueCount: maxSubmitRequeueCount
    pollQueueSubmitBackoff: pollQueueSubmitBackoff
    pdfSubmitQueueBackoff: pdfSubmitQueueBackoff
    textEnrichmentQueue: textEnrichmentQueue
    imageEnrichmentQueue: imageEnrichmentQueue
    maxPollingRequeueCount: maxPollingRequeueCount
    submitRequeueHideSeconds: submitRequeueHideSeconds
    pollingBackoff: pollingBackoff
    maxReadAttempts: maxReadAttempts
    enrichmentEndpoint: enrichment.outputs.cognitiveServiceEndpoint
    enrichmentName: enrichment.outputs.cognitiveServicerAccountName
    enrichmentLocation: location
    targetTranslationLanguage: targetTranslationLanguage
    maxEnrichmentRequeueCount: maxEnrichmentRequeueCount
    enrichmentBackoff: enrichmentBackoff
    enableDevCode: enableDevCode
    EMBEDDINGS_QUEUE: embeddingsQueue
    azureSearchIndex: searchIndexName
    azureSearchServiceEndpoint: searchServices.outputs.endpoint

  }
  dependsOn: [
    appServicePlan
    storage
    cosmosdb
    kvModule
  ]
}


output AZURE_LOCATION string = location
output AZURE_OPENAI_SERVICE string = azureOpenAIServiceName //cognitiveServices.outputs.name
output AZURE_SEARCH_INDEX string = searchIndexName
output AZURE_SEARCH_SERVICE string = searchServices.outputs.name
output AZURE_SEARCH_SERVICE_ENDPOINT string = searchServices.outputs.endpoint
output AZURE_STORAGE_ACCOUNT string = storage.outputs.name
output AZURE_STORAGE_ACCOUNT_ENDPOINT string = storage.outputs.primaryEndpoints.blob
output AZURE_STORAGE_CONTAINER string = containerName
output AZURE_STORAGE_UPLOAD_CONTAINER string = uploadContainerName
output BACKEND_URI string = backend.outputs.uri
output BACKEND_NAME string = backend.outputs.name
output RESOURCE_GROUP_NAME string = rg.name
output AZURE_OPENAI_CHAT_GPT_DEPLOYMENT string = !empty(chatGptDeploymentName) ? chatGptDeploymentName : !empty(chatGptModelName) ? chatGptModelName : 'gpt-35-turbo-16k'
output AZURE_OPENAI_RESOURCE_GROUP string = azureOpenAIResourceGroup
output AZURE_FUNCTION_APP_NAME string = functions.outputs.name
output AZURE_COSMOSDB_URL string = cosmosdb.outputs.CosmosDBEndpointURL
output AZURE_COSMOSDB_LOG_DATABASE_NAME string = cosmosdb.outputs.CosmosDBLogDatabaseName
output AZURE_COSMOSDB_LOG_CONTAINER_NAME string = cosmosdb.outputs.CosmosDBLogContainerName
output AZURE_COSMOSDB_TAGS_DATABASE_NAME string = cosmosdb.outputs.CosmosDBTagsDatabaseName
output AZURE_COSMOSDB_TAGS_CONTAINER_NAME string = cosmosdb.outputs.CosmosDBTagsContainerName
output AZURE_FORM_RECOGNIZER_ENDPOINT string = formrecognizer.outputs.formRecognizerAccountEndpoint
output AZURE_BLOB_DROP_STORAGE_CONTAINER string = uploadContainerName
output AZURE_BLOB_LOG_STORAGE_CONTAINER string = functionLogsContainerName
output CHUNK_TARGET_SIZE string = chunkTargetSize
output FR_API_VERSION string = formRecognizerApiVersion
output TARGET_PAGES string = targetPages
output ENRICHMENT_ENDPOINT string = enrichment.outputs.cognitiveServiceEndpoint
output ENRICHMENT_NAME string = enrichment.outputs.cognitiveServicerAccountName
output TARGET_TRANSLATION_LANGUAGE string = targetTranslationLanguage
output ENABLE_DEV_CODE bool = enableDevCode
output AZURE_CLIENT_ID string = aadMgmtClientId
output AZURE_TENANT_ID string = tenantId
output AZURE_SUBSCRIPTION_ID string = subscriptionId
output IS_USGOV_DEPLOYMENT bool = isGovCloudDeployment
output BLOB_STORAGE_ACCOUNT_ENDPOINT string = storage.outputs.primaryEndpoints.blob
output EMBEDDING_VECTOR_SIZE string = useAzureOpenAIEmbeddings ? '1536' : sentenceTransformerEmbeddingVectorSize
output TARGET_EMBEDDINGS_MODEL string = useAzureOpenAIEmbeddings ? '${abbrs.openAIEmbeddingModel}${azureOpenAIEmbeddingDeploymentName}' : sentenceTransformersModelName
output AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME string = azureOpenAIEmbeddingDeploymentName
output USE_AZURE_OPENAI_EMBEDDINGS bool = useAzureOpenAIEmbeddings
output EMBEDDING_DEPLOYMENT_NAME string = useAzureOpenAIEmbeddings ? azureOpenAIEmbeddingDeploymentName : sentenceTransformersModelName
output ENRICHMENT_APPSERVICE_NAME string = enrichmentApp.outputs.name 
output DEPLOYMENT_KEYVAULT_NAME string = kvModule.outputs.keyVaultName
