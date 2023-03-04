@description('The location into which your Azure resources should be deployed.')
param location string = resourceGroup().location

@description('Select the type of environment you want to provision. Allowed values are prod and test.')
@allowed([
    'prod'
    'test'
])
param environmentType string

var staticWebAppName = '${environmentType}-swa'

// Define the SKUs for each component based on the environment type.
var envMap = {
    prod: {
        swaSku: 'Standard'
    }
    test: {
        swaSku: 'Free'
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
        name: envMap[environmentType].swaSku
        tier: envMap[environmentType].swaSku
    }
    tags: resourceGroup().tags
}

module dns 'dns.bicep' = {
    name: '${deployment().name}--dns'
    params: {
        cname: '${environmentType}-bicep'
        hostname: staticWebApplication.properties.defaultHostname
    }
    scope: resourceGroup('bilby-group')
}

output hostname string = staticWebApplication.properties.defaultHostname
