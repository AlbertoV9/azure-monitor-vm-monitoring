# Scenario 02 – Disk Space Exhaustion

## Ticket

An application on APPVM-1 is failing to write files. The application team suspects that the VM may be running out of disk space. Investigate the VM’s disk usage and determine whether storage capacity 
is contributing to the incident.

## Investigation Objectives

The initial objective is to determine whether insufficient disk capacity is affecting the application.
The investigation should establish:

•	How much free space is available on the affected VM.

•	Which disk or volume is affected.

•	When the available space started decreasing.

•	Whether the behaviour is abnormal compared with other VMs.

•	Whether application or system events indicate write failures.

•	Whether disk I/O performance is also contributing to the issue.

•	Whether the problem is related to storage capacity or another disk/VM performance issue.


## Lab Simulation

•	Disk space on APPVM-1 was intentionally consumed using fsutil.

•	A large file was repeatedly created until approximately 90% of the disk capacity was occupied.

•	An application error was generated to simulate a failed file write operation.

•	Other VMs were left unaffected to provide a comparison baseline.

Example command used to simulate the application error:
eventcreate /ID 1000 /L APPLICATION /T ERROR /SO DemoApp /D "File write operation failed"

## Investigation
  
1. Identify available disk performance counters
  
Before investigating the incident, available disk-related performance counters were reviewed.
  
Perf
  
| where ObjectName contains "Disk"
  
| summarize count() by CounterName
  
Relevant counters included:

•	% Free Space
  
•	Free Megabytes
  
•	Disk Transfers/sec
  
•	Disk Reads/sec
  
•	Disk Writes/sec
  
•	Disk Read Bytes/sec
  
•	Disk Write Bytes/sec
  
•	Avg. Disk sec/Read
  
•	Avg. Disk sec/Write
  
•	Avg. Disk Queue Length
  
•	Avg. Disk Read Queue Length
  
•	Avg. Disk Write Queue Length
  
•	% Disk Time
  
This helped distinguish between capacity-related problems and potential disk I/O performance problems.
  
2. Investigate free disk space over time
  
The percentage of free space was examined over the previous hour to determine whether the issue was ongoing and whether the available capacity had changed significantly.
  
Perf
  
| where TimeGenerated > ago(1h)
  
| where CounterName == "% Free Space"
  
| summarize min(CounterValue) by bin(TimeGenerated, 5m), Computer
  
| render timechart
  
The time-series view also allows the affected VM to be compared with other VMs and helps identify whether the decrease happened gradually or as a sudden change.
  
3. Investigate available disk capacity
  
Free space in megabytes was also examined to provide an absolute measure of the remaining capacity.
  
Perf
  
| where TimeGenerated > ago(1h)
  
| where CounterName == "Free Megabytes"
  
| summarize min(CounterValue) by bin(TimeGenerated, 5m), Computer
  
| render timechart
  
Using both % Free Space and Free Megabytes provides a more useful view than relying on a single metric.
  
4. Investigate application and system events
  
Windows Event Logs were investigated for errors and warnings occurring around the suspected incident period.
  
Event
  
| where Computer has "APPVM-1"
  
| where TimeGenerated between (datetime(2026-08-25 01:20:00Z) .. now())
  
| where EventLevelName in ("Error", "Warning", "Critical")
  
| project TimeGenerated, Computer, EventLevelName, Source, EventID, RenderedDescription
  
| sort by TimeGenerated desc
  
Application write errors were reviewed alongside the disk capacity timeline to determine whether the two events occurred during the same period.
  
5. Determine whether disk I/O performance is contributing
  
A capacity problem can be confused with a disk performance problem. Disk latency and queue-related metrics were therefore checked.
  
Perf
  
| where Computer == "APPVM-1"
  
| where TimeGenerated between (datetime(2026-08-25 01:20:00Z) .. now())
  
| where CounterName in (
  
    "Avg. Disk Queue Length",
    "Avg. Disk sec/Read",
    "Avg. Disk sec/Write"
  
)
  
| summarize avg(CounterValue)
  
    by bin(TimeGenerated, 5m), CounterName
  
| render timechart
  
This helps determine whether slow disk I/O could be contributing to the application’s inability to write files.
  
6. Check other VM resources
  
Heartbeat, CPU and memory telemetry were also reviewed to determine whether the disk issue was part of a broader VM performance problem.
The affected VM was compared with other VMs to determine whether the behaviour was isolated to APPVM-1.
  
## Findings
  
The available disk space on APPVM-1 decreased significantly during the investigated period. The behaviour was abnormal when compared with the other VMs.
The decrease in available storage coincided with application errors reporting failed file-write operations.
Heartbeat telemetry remained normal, and no abnormal CPU or memory behaviour was identified during the investigation. Disk latency and queue-related metrics also did not show evidence of a 
significant I/O performance problem.
The evidence therefore supports insufficient disk capacity as a likely contributor to the application write failures, rather than a general VM resource or disk-latency problem.
However, the investigation did not determine what originally caused the disk space to be consumed. This would require investigation inside the VM.
  
## Conclusion
  
Azure Monitor telemetry provided evidence that the application write failures were correlated with a significant reduction in available disk capacity on APPVM-1.
The next step would be to identify what consumed the available storage and determine whether the behaviour is expected or caused by an application, log growth, temporary files or another process.
  
## Recommended Next Steps
  
In a production incident, I would continue the investigation by:

•	Identifying which files, directories or application data are consuming the disk space.
  
•	Checking whether the application has permission to write to the destination directory.
  
•	Verifying that the destination directory exists and is accessible.
  
•	Checking that all expected disks are online and attached to the VM.
  
•	Reviewing application and operating system logs for additional write-related errors.
  
•	Determining whether the storage growth is expected or recurring.
  
•	If the disk is genuinely undersized, considering increasing the managed disk capacity and extending the partition/filesystem inside the VM.
  
•	If disk capacity is sufficient but writes continue to fail, investigating application, filesystem and permission-related causes.
  
## Limitations
  
The scenario was simulated by deliberately consuming disk space on the VM and generating an application error. The lab demonstrates the investigation methodology and correlation of monitoring signals 
rather than reproducing a naturally occurring application incident.
The investigation identified a strong correlation between reduced disk capacity and application write errors, but did not establish what originally caused the storage consumption.
