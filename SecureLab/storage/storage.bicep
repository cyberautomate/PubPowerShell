@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the storage account.')
param storageName string = 'dahallcontainerstorage'

@description('The SKU of the storage account.')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param sku string = 'Standard_LRS'

var storageNameCleaned = replace(storageName, '-', '')

resource storage 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageNameCleaned
  location: location
  kind: 'StorageV2'
  sku: {
    name: sku
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: true
    minimumTlsVersion: 'TLS1_2'
  }
}
//TODO: resource to create the file shares for Postgres data and Spectre data
