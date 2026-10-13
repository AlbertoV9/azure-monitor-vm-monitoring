
param location string




resource LAW 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'LAW-prod'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}


resource DCR 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'vmDCR'
  location: location
  properties: {
    dataSources: {
      windowsEventLogs: [
        {
          name: 'event-logs'
          streams: [
            'Microsoft-Event'
          ]
          xPathQueries: [
            'System!*'
            'Application!*'
            'Security!*'
          ]
        }
      ]
      performanceCounters: [
        {
          name: 'performance-counters'
          streams: [
            'Microsoft-Perf'
          ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            '\\Processor(_Total)\\% Processor Time'
            '\\Memory\\Available MBytes'
            '\\LogicalDisk(_Total)\\% Free Space'
            '\\LogicalDisk(_Total)\\Disk Transfers/sec'
            '\\Network Interface(*)\\Bytes Total/sec'
          ]
        }
      ]      
    } 
    destinations: {
      logAnalytics: [
        {
          name: 'law-destination'
          workspaceResourceId: LAW.id
        }
      ]
    } 
    dataFlows: [
      {
        streams: [
          'Microsoft-Event'
        ]
        destinations: [
          'law-destination'
        ]
      }
      {
        streams: [
          'Microsoft-Perf'
        ]
        destinations: [
          'law-destination'
        ]
      }
    ]
  }
}


output dcrID string = DCR.id
