param cname string
param hostname string

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
    name: 'bilby.social'
}

resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
    name: cname
    parent: dnsZone
    properties: {
        TTL: 3600
        CNAMERecord: {
            cname: hostname
        }
    }
}
