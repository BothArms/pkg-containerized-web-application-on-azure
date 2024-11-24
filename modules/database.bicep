param projectName string

param mysqlSubnetId string
param mysqlPrivateDnsZoneId string
param mysqlUser string
param mysqlDatabase string
@secure()
param mysqlPassword string


resource flexibleServer 'Microsoft.DBforMySQL/flexibleServers@2023-06-01-preview' = {
  name: 'flexible-server-${projectName}'
  location: resourceGroup().location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    version: '8.0.21'
    administratorLogin: mysqlUser
    administratorLoginPassword: mysqlPassword
    storage: {
      storageSizeGB: 20
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    network: {
      delegatedSubnetResourceId: mysqlSubnetId
      privateDnsZoneResourceId: mysqlPrivateDnsZoneId
    }
  }
}

resource database 'Microsoft.DBforMySQL/flexibleServers/databases@2023-06-01-preview' = {
  parent: flexibleServer
  name: mysqlDatabase
  properties: {
    charset: 'utf8'
    collation: 'utf8_general_ci'
  }
}


output hostname string = replace(flexibleServer.properties.fullyQualifiedDomainName,
  '.mysql.database.azure.com',
  '.private.mysql.database.azure.com')

