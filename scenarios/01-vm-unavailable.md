Scenario 01 – VM Unavailable / Unexpected Restart
Ticket
Users report that an application hosted on APPVM-1 became unavailable. Investigate whether the VM experienced an availability issue or unexpected restart and determine approximately when the incident occurred.
Investigation Objectives
The first objective is to determine whether the VM itself became unavailable or whether the problem was isolated to the application or one of its dependencies.
The investigation should establish:
•	When the incident occurred and approximately how long it lasted.
•	Whether APPVM-1 stopped reporting telemetry during the incident.
•	Whether other VMs experienced the same issue.
•	Whether the VM restarted or experienced an operating system failure.
•	Whether resource pressure or another VM-level issue could have contributed to the incident.
•	Whether application or system events provide additional evidence.
•	Whether further investigation outside Azure Monitor is required.
The investigation follows the principle of first establishing the scope of the failure before assuming that the VM itself is the cause.
Lab Simulation
•	CPU and memory usage were artificially increased using PowerShell.
•	APPVM-1 was then stopped from the Azure Portal to simulate VM unavailability.
•	Application error events were generated using PowerShell.
•	No real application was hosted on the VM; the scenario focuses on investigating the VM and its telemetry.
Investigation
1. Determine whether the VM stopped reporting
The first step was to compare the heartbeat data from APPVM-1 with the other VMs reporting to the same Log Analytics Workspace.
Heartbeat
| where TimeGenerated between (datetime(2026-08-25 08:23:00Z) .. datetime(2026-08-25 08:28:00Z))
| summarize count() by bin(TimeGenerated, 5m), Computer
| render timechart
This helps determine whether the affected VM stopped sending heartbeats while other VMs continued to report normally.
2. Investigate the heartbeat gap
After identifying a potential interruption, the heartbeat records for APPVM-1 were examined in more detail.
Heartbeat
| where Computer has "AppVM-1"
| where TimeGenerated between (datetime(2026-08-25 08:23:00Z) .. datetime(2026-08-25 08:28:00Z))
| sort by TimeGenerated desc
The purpose was to identify the last heartbeat before the interruption and determine when telemetry resumed.
3. Investigate resource pressure
CPU and memory telemetry was examined around the incident and compared with other VMs.
Perf
| where CounterName == "% Processor Time"
| where TimeGenerated between (datetime(2026-08-25 08:00:00Z) .. datetime(2026-08-25 08:30:00Z))
| project TimeGenerated, Computer, CounterName, CounterValue
| render timechart
Perf
| where CounterName == "Available Bytes"
| where TimeGenerated between (datetime(2026-08-25 08:00:00Z) .. datetime(2026-08-25 08:30:00Z))
| project TimeGenerated, Computer, CounterName, CounterValue
| render timechart
Additional disk performance data was reviewed to determine whether storage activity could have contributed to the VM becoming unresponsive.
Perf
| where CounterName == "Avg. Disk Queue Length"
| summarize avg(CounterValue) by bin(TimeGenerated, 1m), Computer
| render timechart
4. Investigate Windows Events
Windows Event Logs were investigated for errors related to the application or potential system problems around the incident.
Event
| where Computer has "AppVM-1"
| where TimeGenerated between (datetime(2026-08-25 08:00:00Z) .. datetime(2026-08-25 08:30:00Z))
| where EventLevelName !has "Information"
| where Source has "MyApp"
Application errors were found during the investigation and were considered alongside the resource telemetry.
Findings
APPVM-1 stopped sending heartbeats between approximately 10:23 and 10:28, while the other VMs continued reporting normally. This indicates that the telemetry interruption was isolated to APPVM-1 rather than affecting the entire Log Analytics Workspace or monitoring environment.
Azure Monitor Agent was present on the VM and the VM resumed sending heartbeat telemetry after it was restarted.
Before the interruption, APPVM-1 experienced elevated CPU and memory usage. Application error events were also observed around the investigation period.
The available evidence therefore indicates that the VM experienced an availability interruption preceded by significant resource pressure. However, the collected telemetry does not conclusively establish that CPU or memory exhaustion was the root cause of the crash.
Conclusion
The investigation established that APPVM-1 itself stopped reporting during the incident rather than simply losing one specific telemetry stream.
The most likely area for further investigation is the VM and its workload immediately before the failure. Resource pressure and application errors provide potential contributing factors, but additional evidence would be required to establish the root cause.
Recommended Next Steps
In a production incident, I would continue the investigation by:
•	Checking Azure Activity Log for VM state changes, restarts, provisioning changes or failed extensions.
•	Reviewing Boot Diagnostics and operating system crash information.
•	Identifying the processes responsible for the CPU and memory consumption.
•	Reviewing Windows critical and error-level events for evidence of an operating system failure.
•	Reviewing application logs in more detail.
•	Verifying whether the application service is running and listening on the expected port.
•	Testing application connectivity locally from the VM.
•	If the application is reachable locally but not remotely, continuing with NSG, Windows Firewall and network connectivity investigation.
•	Checking whether the application has redundant instances and whether APPVM-2 was able to continue serving users during the incident.
Limitations
The scenario was simulated in a lab environment and did not contain a real application workload. The VM was deliberately stopped after generating resource pressure, so the investigation demonstrates the troubleshooting methodology rather than reproducing a naturally occurring operating system crash.
The observed correlation between resource pressure, application errors and VM unavailability should therefore be treated as evidence for further investigation rather than definitive proof of root cause.

