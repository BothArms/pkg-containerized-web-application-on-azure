param projectName string
param containerName string
param containerAppsSubnetId string

param mysqlHost string
param mysqlPort int
param mysqlUser string
param mysqlDatabase string
@secure()
param mysqlPassword string

param redisName string
param redisHost string
param redisPort int


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

resource existingRedis 'Microsoft.Cache/redis@2023-08-01' existing = {
  name: redisName
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
              value: mysqlHost
            }
            {
              name: 'MYSQL_PORT'
              value: string(mysqlPort)
            }
            {
              name: 'MYSQL_USER'
              value: mysqlUser
            }
            {
              name: 'MYSQL_PASSWORD'
              value: mysqlPassword
            }
            {
              name: 'MYSQL_DATABASE'
              value: mysqlDatabase
            }
            {
              name: 'REDIS_HOST'
              value: redisHost
            }
            {
              name: 'REDIS_PORT'
              value: string(redisPort)
            }
            {
              name: 'REDIS_PASSWORD'
              value: existingRedis.listKeys().primaryKey
            }
            {
              name: 'HELLO'
              value: 'world'
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
