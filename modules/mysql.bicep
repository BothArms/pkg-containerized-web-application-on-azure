@description('ID of the MySQL subnet.')
param mysqlSubnetId string

@description('ID of the MySQL private DNS zone.')
param mysqlPrivateDnsZoneId string

@description('Name of the MySQL flexible server.')
param mysqlName string

@description('Admin username for MySQL server.')
param mysqlUser string

@description('Name of the MySQL database.')
param mysqlDatabase string

@description('Admin password for MySQL server.')
@secure()
param mysqlPassword string


resource flexibleServer 'Microsoft.DBforMySQL/flexibleServers@2023-06-01-preview' = {
  name: mysqlName
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

