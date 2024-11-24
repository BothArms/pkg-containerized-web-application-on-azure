@description('Name of the Redis cache instance.')
param redisName string

resource redis 'Microsoft.Cache/redis@2023-08-01' = {
  name: redisName
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Standard'
      family: 'C'
      capacity: 0
    }
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    redisConfiguration: {
      'maxmemory-policy': 'allkeys-lru'
    }
    redisVersion: '6.0'
    publicNetworkAccess: 'Disabled'
  }
}

output redisId string = redis.id
