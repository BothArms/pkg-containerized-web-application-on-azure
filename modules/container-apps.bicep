@description('Name of the project used to generate unique resource names.')
param projectName string

@description('ID of the Container Apps subnet.')
param containerAppsSubnetId string

@description('Name of the container app.')
param containerName string

@description('Name of the MySQL flexible server.')
param mysqlName string

@description('Name of the Redis cache instance.')
param redisName string

@description('Name of the MySQL database.')
param mysqlDatabase string

@description('Admin password for MySQL server.')
@secure()
param mysqlAdminPassword string

resource existingRedis 'Microsoft.Cache/redis@2023-08-01' existing = {
  name: redisName
}
resource existingMysql 'Microsoft.DBforMySQL/flexibleServers@2023-06-01-preview' existing = {
  name: mysqlName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: 'containerregistry${projectName}'
  location: resourceGroup().location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
  }
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: 'container-app-env-${projectName}'
  location: resourceGroup().location
  properties: {
    zoneRedundant: false
    infrastructureResourceGroup: resourceGroup().name
    vnetConfiguration: {
      infrastructureSubnetId: containerAppsSubnetId
      internal: false
    }
  }
}


resource containerApps 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'container-app-${projectName}'
  location: resourceGroup().location
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 3000
      }
      secrets: [
        {
          name: 'registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.listCredentials().username
          passwordSecretRef: 'registry-password'
        }
      ]
    }
    template: {
      containers: [
        {
          name: containerName
          image: '${containerRegistry.properties.loginServer}/${containerName}:latest'
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'MYSQL_HOST'
              value: replace(existingMysql.properties.fullyQualifiedDomainName, '.mysql.database.azure.com', '.private.mysql.database.azure.com')
            }
            {
              name: 'MYSQL_PORT'
              value: '3306'
            }
            {
              name: 'MYSQL_USER'
              value: existingMysql.properties.administratorLogin
            }
            {
              name: 'MYSQL_PASSWORD'
              value: mysqlAdminPassword
            }
            {
              name: 'MYSQL_DATABASE'
              value: mysqlDatabase
            }
            {
              name: 'REDIS_HOST'
              value: existingRedis.properties.hostName
            }
            {
              name: 'REDIS_PORT'
              value: '6380'
            }
            {
              name: 'REDIS_PASSWORD'
              value: existingRedis.listKeys().primaryKey
            }
            {
              name: 'REDIS_TLS'
              value: 'true'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}
