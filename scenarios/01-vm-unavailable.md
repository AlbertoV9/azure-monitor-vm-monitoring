# Scenario 01 – VM Unavailable / Unexpected Restart

## Ticket
Users report that an application hosted on APPVM-1 became unavailable. Investigate whether the VM experienced an availability issue or unexpected restart and determine approximately when the incident occurred.

## Investigation Objectives
First, I would check if it was the VM that has become unavailable. There may be different reasons why it may have become unavailable: 
- It may have lagged because of CPU or memory being depleted which can have their own reasons 
- it may have had some OS crash which also can be cause by different factors 
- it may have been some networking issue which prevented the app to communicate, it may have also prevented VM to send heartbeats and networking issues also have different causes
Second option is that the app itself has become unavailable, which can lead to the app issues itself or issues with some dependencies. 
Questions:
Is the app highly available, does it have redundancy VMs which can take over the load? Do the other VMs also experience this issue or is it only the AppVM-1? 
When was the time of occurrence and for how long the app has been unavailable? 
Investigation:
- If we don’t have the time of occurrence or the duration of unavailability, we need to determine if the VM has restarted in the time range of the app being unavailable, we can check this in activity
  logs or query the activity logs telemetry in LAW to find the  …
- check if there was some gap in sending heartbeat of the AppVM-1 and compare to other VMs mapped to same LAW and DCR
- investigate with LAW if there was some CPU or memory breach during the incident time 
- investigate networking telemetry to check if there was some connectivity issue 
- investigate the events log in the time of incident to discover if there is any crash related event 
- investigate boot events

## Lab Simulation
- artificially overloaded the CPU and memory by loops in PowerShell and then stopped VM from the Azure Portal 
- no actual app is running on the VM, the case here is the VM issue 
- generated Application error Events via Powershell


## Investigation:

### 1. Discover the heartbeat count of the VM during the incident time in comparison with other VMs mapped to the LAW with same DCR

Heartbeat
| where TimeGenerated between(datetime(2026-08-25 8:23:00Z) .. datetime(2026-08-25 8:28:00Z))
| summarize count()by bin(TimeGenerated, 5min), Computer
| render timechart


### 2. Investigate further the gap in heartbeat arrival of the specified VM
Heartbeat
| where Computer has "AppVM-1" and TimeGenerated between(datetime(2026-08-25 8:23:00Z) .. datetime(2026-08-25 8:28:00Z))

### 3. When the gap started, When the gap ended, what was the last heartbeat before the arrival interruption, when was the first heartbeat after heartbeat retrieval
Heartbeat
| where Computer == "AppVM-1"
| where TimeGenerated between (datetime(2026-08-25 10:15) .. datetime(2026-08-25 10:35))
| project TimeGenerated
| sort by TimeGenerated desc


Discover the processor performance around the time of the incident and compare to the data of other VMs with similar workload
Perf
| where CounterName has "% Processor Time" and TimeGenerated between (datetime(2026-08-25 8:00:00Z) .. datetime(2026-08-25 8:30:00Z))
| project TimeGenerated, Computer, CounterName, CounterValue
| render timechart

Discover the memory usage around the time of the incident and compare to the data of other VMs with similar workload
Perf
| where CounterName has "Available Bytes" and TimeGenerated between (datetime(2026-08-25 8:00:00Z) .. datetime(2026-08-25 8:30:00Z))
| project TimeGenerated, Computer, CounterName, CounterValue
| render timechart



Investigate the Event logs to find any related event to the crash, resources overload or application issue
Event
| where Computer has "AppVM-1" and TimeGenerated between (datetime(2026-08-25 8:00:00Z) .. datetime(2026-08-25 8:30:00Z))
| where EventLevelName !has "Information"
| where Source has "MyApp"

Investigate the disk queue in the time of incident and compare to the data of other VMs with similar workload
Perf
| where CounterName == "Avg. Disk Queue Length"
| summarize avg(CounterValue) by bin(TimeGenerated, 1min), Computer
| render timechart


Perf
| where CounterName has "Available Bytes" and TimeGenerated between (datetime(2026-08-25 8:00:00Z) .. datetime(2026-08-25 8:30:00Z))
| summarize min(CounterValue) by bin(TimeGenerated, 1min), Computer, CounterName, CounterValue
| render timechart


Perf
| where CounterName has "% Processor Time" and TimeGenerated between (datetime(2026-08-25 8:00:00Z) .. datetime(2026-08-25 8:30:00Z))
| summarize max(CounterValue) by bin(TimeGenerated, 1min), Computer, CounterName, CounterValue
| render timechart



Findings:
By investigation it was found that the VM has stopped sending heartbeats between 10:23 and 10:28 in comparison other VMs kept sending heartbeats.
As checked the AMA was present in the Extensions and Applications, furthermore the VM begun again to send heartbeats after being rebooted. 
The VM has had CPU and memory overloaded before crashing. By investigating further there were Application errors events found.  
To discover the root cause, it would be recommended to investigate which processes has consumed the CPU and memory. It would be also recommended to investigate the crash logs of the VM and the App error logs. 
Furthermore analyze the Event Logs critical/error level related to OS failure. 

Additional from internet and AI research:
Check Boot diagnostics
Check Activity Log changes 
-	look for provisioning errors or failed extensions
Check application service and restart via remote control 
Test app access from the VM itself, curl http://localhost:<port>
-	check if the app is listening and if the correct port is assigned 
Include validation of network connectivity such as checking if NSG is blocking traffic or VM firewall
