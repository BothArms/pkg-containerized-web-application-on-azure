@description('Name of the project used to generate unique resource names.')
param projectName string

@description('ID of the Redis cache instance.')
param redisId string

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-${projectName}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'container-apps-subnet'
        properties: {
          addressPrefix: '10.0.0.0/23'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'mysql-subnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          delegations: [
            {
              name: 'Microsoft.DBforMySQL.flexibleServers'
              properties: {
                serviceName: 'Microsoft.DBforMySQL/flexibleServers'
              }
            }
          ]
        }
      }
      {
        name: 'redis-subnet'
        properties: {
          addressPrefix: '10.0.3.0/24'
        }
      }
    ]
  }
}

resource mysqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'private.mysql.database.azure.com'
  location: 'global'
}

resource mysqlPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: mysqlPrivateDnsZone
  name: 'mysql-link-${projectName}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource redisPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.redis.cache.windows.net'
  location: 'global'
}

resource redisPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: redisPrivateDnsZone
  name: 'redis-link-${projectName}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-03-01' = {
  name: 'private-endpoint-${projectName}'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: vnet.properties.subnets[2].id
    }
    privateLinkServiceConnections: [
      {
        name: 'redis-connection'
        properties: {
          privateLinkServiceId: redisId
          groupIds: [
            'redisCache'
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-03-01' = {
  name: 'redis-dns-group-${projectName}'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'redis-config'
        properties: {
          privateDnsZoneId: redisPrivateDnsZone.id
        }
      }
    ]
  }
}


output containerAppsSubnetId string = vnet.properties.subnets[0].id

output mysqlSubnetId string = vnet.properties.subnets[1].id
output mysqlPrivateDnsZoneId string = mysqlPrivateDnsZone.id

output redisSubnetId string = vnet.properties.subnets[2].id
output redisPrivateDnsZoneId string = redisPrivateDnsZone.id
