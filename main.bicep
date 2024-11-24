targetScope = 'subscription'

param location string = 'japaneast'
param projectName string = 'cwa'

param containerName string = 'web-app'

param mysqlPort int = 3306
param mysqlUser string = 'mysqladmin'
param mysqlDatabase string = 'mysqldb'
@secure()
param mysqlPassword string = newGuid()

param redisName string = 'redis-${projectName}'
param redisPort int = 6380

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-${projectName}'
  location: location
}

module cache 'modules/cache.bicep' = {
  name: 'cache'
  scope: rg
  params: {
    redisName: redisName
  }
}

module network 'modules/network.bicep' = {
  name: 'network'
  scope: rg
  params: {
    projectName: projectName
    redisId: cache.outputs.redisId
  }
}

module database 'modules/database.bicep' = {
  name: 'database'
  scope: rg
  params: {
    projectName: projectName
    mysqlSubnetId: network.outputs.mysqlSubnetId
    mysqlPrivateDnsZoneId: network.outputs.mysqlPrivateDnsZoneId
    mysqlDatabase: mysqlDatabase
    mysqlUser: mysqlUser
    mysqlPassword: mysqlPassword
  }
}

module containerApps 'modules/container-apps.bicep' = {
  name: 'container-apps'
  scope: rg
  params: {
    projectName: projectName
    containerAppsSubnetId: network.outputs.containerAppsSubnetId
    containerName: containerName
    mysqlDatabase: mysqlDatabase
    mysqlHost: database.outputs.hostname
    mysqlPassword: mysqlPassword
    mysqlPort: mysqlPort
    mysqlUser: mysqlUser
    redisName: redisName
    redisHost: cache.outputs.redisHost
    redisPort: redisPort
  }
}
