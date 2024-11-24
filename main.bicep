targetScope = 'subscription'

@description('Location for all resources.')
param location string = 'japaneast'

@description('Name of the project used to generate unique resource names.')
param projectName string = 'cwa'

@description('Name of the container app.')
param containerName string = 'web-app'

@description('Name of the Redis cache instance.')
param redisName string = 'redis-${projectName}'

@description('Name of the MySQL flexible server.')
param mysqlName string = 'mysql-${projectName}'

@description('Admin username for MySQL server.')
param mysqlUser string = 'mysqladmin'

@description('Name of the MySQL database.')
param mysqlDatabase string = 'mysqldb'

@description('Admin password for MySQL server.')
@secure()
param mysqlPassword string = newGuid()


// Create a new resource group to contain all resources
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'resource-group-${projectName}'
  location: location
}

// Deploy Redis Cache instance using the redis module
module redis 'modules/redis.bicep' = {
  name: 'redis'
  scope: resourceGroup
  params: {
    redisName: redisName
  }
}

// Deploy Virtual Network with subnets for Redis, MySQL, and Container Apps
module vnet 'modules/vnet.bicep' = {
  name: 'vnet'
  scope: resourceGroup
  params: {
    projectName: projectName
    redisId: redis.outputs.redisId
  }
  dependsOn: [
    redis
  ]
}

// Deploy MySQL flexible server using the mysql module
module mysql 'modules/mysql.bicep' = {
  name: 'mysql'
  scope: resourceGroup
  params: {
    mysqlSubnetId: vnet.outputs.mysqlSubnetId
    mysqlPrivateDnsZoneId: vnet.outputs.mysqlPrivateDnsZoneId
    mysqlName: mysqlName
    mysqlDatabase: mysqlDatabase
    mysqlUser: mysqlUser
    mysqlPassword: mysqlPassword
  }
  dependsOn: [
    vnet
  ]
}

// Deploy Container Apps environment and container app using the container-apps module
module containerApps 'modules/container-apps.bicep' = {
  name: 'container-apps'
  scope: resourceGroup
  params: {
    projectName: projectName
    containerAppsSubnetId: vnet.outputs.containerAppsSubnetId
    containerName: containerName
    mysqlName: mysqlName
    redisName: redisName
    mysqlDatabase: mysqlDatabase
    mysqlAdminPassword: mysqlPassword
  }
  dependsOn: [
    vnet
    redis
    mysql
  ]
}
