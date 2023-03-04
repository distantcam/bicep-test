@description('Select the type of environment you want to provision. Allowed values are prod and test.')
@allowed([
    'prod'
    'test'
])
param environmentType string

param hostname string

resource customDns 'Microsoft.Web/staticSites/customDomains@2022-03-01' = {
    name: '${environmentType}-swa/${hostname}'
}
