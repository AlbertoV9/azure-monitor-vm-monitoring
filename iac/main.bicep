
param location string = 'EastUS'
param vmSize string = 'Standard_DS1_v2'
@secure()
param vmLogin string
@secure()
param vmPassword string
param vmAZInstancesCount int = 2
param vmTypes array = [
  appVMName
  webVMNAme
]
param appVMName string = 'appVM'
param webVMNAme string = 'webVM'







module appVM 'VMs.bicep' = {
  name: 'appVMDeployment'
  params: {
    vmLogin: vmLogin
    vmName: appVMName
    vmPassword: vmPassword
    vmAZInstancesCount: vmAZInstancesCount
    vmSize: vmSize
    location: location
    subnetReference: Vnet.outputs.subnets[0].id
    dcrAssociation: LAW.outputs.dcrID
  }
}

module webVM 'VMs.bicep' = {
  name: 'webVMDeployment'
  params: {
    vmLogin: vmLogin
    vmName: webVMNAme
    vmPassword: vmPassword
    vmAZInstancesCount: vmAZInstancesCount
    vmSize: vmSize
    location: location
    subnetReference: Vnet.outputs.subnets[1].id
    dcrAssociation: LAW.outputs.dcrID
  }
}

module Vnet 'Vnet.bicep' = {
  params: {
    location: location
    vmTypes: vmTypes
  }
}


module LAW 'logAnalyticsWorkspace.bicep' = {
  params: {
    location: location
  }
}
