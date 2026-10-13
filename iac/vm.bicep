param location string 
param vmSize string 
@secure()
param vmLogin string
@secure()
param vmPassword string
param vmAZInstancesCount int 
param vmName  string
param subnetReference string
param dcrAssociation string


resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-03-01' = [for (instance, i) in range(1, vmAZInstancesCount): {
  location: location
  name:  '${vmName}${instance}'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      adminUsername: vmLogin
      adminPassword: vmPassword
      computerName:  '${vmName}${instance}'
    } 
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        version: 'latest'
        sku: '2022-Datacenter'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: NIC[i].id
          properties: {
            primary: true
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }  
  zones: [
    string(instance % 3 + 1)
  ]
}]


resource NIC 'Microsoft.Network/networkInterfaces@2022-07-01' = [for (instance, i) in range(1, vmAZInstancesCount): {
  name: '${vmName}${i+1}NIC'
  location: location
  properties: {
    enableIPForwarding: false
    ipConfigurations: [
      {
       name: 'NICIPConfig'
       properties: {
        subnet: {
          id: subnetReference
        }
        primary: true
        privateIPAddressVersion: 'IPv4'
        privateIPAllocationMethod: 'Dynamic'


       }
      }
    ]
    nicType: 'Standard'
  }
}]


resource AMA 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = [for (instance, i) in range(1, vmAZInstancesCount): {
  name: '${virtualMachine[i].name}-AMA'
  parent: virtualMachine[i]
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
  }
}]

resource dcrAssociations 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = [for (instance, i) in range(1, vmAZInstancesCount): {
  name: '${virtualMachine[i].name}dcrAssociations'
  scope: virtualMachine[i]
  properties: {
     dataCollectionRuleId: dcrAssociation
     description: 'Association of data collection rules to the VMs'
  }
}]

