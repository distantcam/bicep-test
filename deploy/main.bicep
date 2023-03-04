@description('The location into which your Azure resources should be deployed.')
param location string = resourceGroup().location

@description('Select the type of environment you want to provision. Allowed values are Production and Test.')
@allowed([
    'Production'
    'Test'
])
param environmentType string

@description('A unique suffix to add to resource names that need to be globally unique.')
@maxLength(13)
param resourceNameSuffix string = uniqueString(resourceGroup().id)

// Define the names for resources.
var staticWebAppName = 'test-swa-${resourceNameSuffix}'

// Define the SKUs for each component based on the environment type.
var environmentConfigurationMap = {
    Production: {
        cname: 'bicep'
        staticWebApp: {
            sku: {
                name: 'Standard'
                tier: 'Standard'
            }
        }
    }
    Test: {
        cname: 'test-bc'
        staticWebApp: {
            sku: {
                name: 'Free'
                tier: 'Free'
            }
        }
    }
}

resource staticWebApplication 'Microsoft.Web/staticSites@2022-03-01' = {
    name: staticWebAppName
    location: location
    properties: {
        stagingEnvironmentPolicy: 'Enabled'
        allowConfigFileUpdates: true
    }
    sku: {
        name: environmentConfigurationMap[environmentType].staticWebApp.sku.name
        tier: environmentConfigurationMap[environmentType].staticWebApp.sku.tier
    }
    tags: resourceGroup().tags
}

module bilby 'dns.bicep' = {
    name: 'bilbyDns'
    scope: resourceGroup('bilby-group')
    params: {
        cname: environmentConfigurationMap[environmentType].cname
        hostname: staticWebApplication.properties.defaultHostname
    }
}

resource staticWebApplicationDomain 'Microsoft.Web/staticSites/customDomains@2022-03-01' = {
    name: environmentConfigurationMap[environmentType].fqdn
    parent: staticWebApplication
}

output hostname string = staticWebApplication.properties.defaultHostname
