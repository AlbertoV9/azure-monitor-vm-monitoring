

param location string
param vmTypes array 


var vNetName = 'vNet'



resource vNet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [     
      for (vmType, i) in vmTypes: {
        name: '${vmType}Subnet'
        properties: {
          addressPrefix: '10.0.${i}.0/24'
          networkSecurityGroup: {
          id: NSG.id    
          }       
        }
      }
    ]
  }
}


/* resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = [for (vmType, i) in vmTypes: {
  name: '${vmType}Subnet'
  parent: vNet
  properties: {
    addressPrefix: '10.0.${i}.0/24'
    networkSecurityGroup: {
      id: NSG.id
    }
  }
}] */


resource NSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'defaultNSG'
  location: location
}

output subnets array = vNet.properties.subnets
