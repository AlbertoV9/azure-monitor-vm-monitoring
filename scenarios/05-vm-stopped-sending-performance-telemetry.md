# Scenario 05 – VM Stopped Sending Performance Telemetry

## Ticket

The analytics team reports that APPVM-2 has stopped reporting performance telemetry to Log Analytics, while heartbeat and Windows Event data continue to arrive. Investigate when the performance telemetry stopped, 
identify the likely cause and restore monitoring.

## Investigation Objectives

The main objective is to determine whether the missing performance data is caused by an issue with the VM, Azure Monitor Agent (AMA), Data Collection Rule (DCR), or the telemetry ingestion configuration.
The investigation follows the telemetry path from the VM to Log Analytics:

Heartbeat → Performance data → Compare with healthy VMs → Identify telemetry gap → AMA status → DCR association → Data ingestion → Remediation → Verification

The fact that heartbeat and Event data continue to arrive is important because it indicates that the VM is still communicating with Azure Monitor and that telemetry ingestion is not completely unavailable.

## Investigation Questions

•	When was the last performance telemetry received from APPVM-2?

•	Are other VMs still sending performance telemetry?

•	Are heartbeat and Windows Event data still arriving from APPVM-2?

•	Is Azure Monitor Agent installed and in a provisioned state?

•	Is APPVM-2 associated with the expected DCR?

•	Does the DCR contain the required performance counter data source?

•	Were there any changes to the VM or monitoring configuration around the time the telemetry stopped?

•	If the configuration is correct, are there any AMA or connectivity issues that could prevent telemetry collection?

## Lab Simulation

The scenario was simulated by changing the monitoring configuration so that APPVM-2 no longer received performance counter collection.
The original approach was to modify the DCR transformation to exclude APPVM-2. However, the available transformation schema did not expose the required Computer column for this scenario.
To avoid spending additional time on the simulation, a separate test DCR was created and associated with APPVM-2. The test DCR did not contain performance counters as a data source.
This simulated a situation where a VM could be associated with an incorrect DCR or where a monitoring configuration change could result in performance telemetry no longer being collected.

## Investigation

### 1. Check the latest performance telemetry for APPVM-2

Perf

| where Computer == "AppVM-2"

| sort by TimeGenerated desc

| take 10

![perf-logs-check](../screenshots/scenario-03/perf-logs-check.png)

This establishes when performance telemetry was last received from the affected VM.

### 2. Compare the latest telemetry across VMs

Check the latest performance, Event and Heartbeat data for each VM.

Perf

| where TimeGenerated > ago(1d)

| sort by TimeGenerated

| summarize max(TimeGenerated) by Computer

![perf-by-vm](../screenshots/scenario-03/perf-by-vm.png)

Event

| where TimeGenerated > ago(1d)

| sort by TimeGenerated

| summarize max(TimeGenerated) by Computer

![event-logs-compare](../screenshots/scenario-03/event-logs-compare.png)

Heartbeat

| where TimeGenerated > ago(1d)

| sort by TimeGenerated

| summarize max(TimeGenerated) by Computer

Comparing the three data sources helps determine whether the problem affects all telemetry from the VM or only a specific type of telemetry.

### 3. Check whether heartbeat and Event data are still arriving

Event

| where Computer == "AppVM-2"

| sort by TimeGenerated desc

| take 10

![event-logs-check](../screenshots/scenario-03/event-logs-check.png)

Heartbeat

| where Computer == "AppVM-2"

| sort by TimeGenerated desc

| take 10

![heartbeat-logs](../screenshots/scenario-03/heartbeat-logs.png)

Heartbeat and Event data continued to arrive while performance telemetry was missing.
This indicates that the VM was still reporting telemetry and that the issue was specific to performance data collection rather than a complete loss of monitoring.

### 4. Check Azure Activity Log for configuration changes

AzureActivity

| where TimeGenerated between (
    datetime(2026-08-29 15:00:00Z)
    ..
    datetime(2026-08-29 15:40:00Z)
)

| sort by TimeGenerated desc

The Activity Log was investigated for changes to the VM or monitoring configuration around the time performance telemetry stopped arriving.

### 5. Check AMA configuration

The Azure Monitor Agent was checked on APPVM-2 and was found to be present and provisioned.

As part of the troubleshooting process, the following AMA troubleshooting areas were also reviewed:

•	AMA extension logs:

C:\WindowsAzure\Logs\Plugins\Microsoft.Azure.Monitor.AzureMonitorWindowsAgent

•	AMA configuration:

C:\WindowsAzure\Resources\AMADataStore.<virtual-machine-name>\Configuration

•	DCR configuration files under the AMA data store

•	Latest DCR configuration downloaded to the VM

•	AMA connectivity and related errors

•	Performance counter configuration in the DCR

These checks provide a deeper troubleshooting path if the problem cannot be explained by the Azure configuration.

### 6. Check DCR association and configuration

The DCR associations for APPVM-2 were investigated.

The investigation showed that APPVM-2 was associated with DCR-Test instead of the expected DCR-Prod.

DCR-Test did not contain performance counters as a data source.

This explained why heartbeat and Event data continued to arrive while performance telemetry was missing.

## Findings

Performance telemetry from APPVM-2 was no longer being received, while heartbeat and Windows Event data continued to arrive.
This indicated that the VM and Azure Monitor Agent were still functioning sufficiently to send telemetry and that the issue was specific to the performance data collection configuration.
The DCR configuration was then investigated and it was found that APPVM-2 was associated with DCR-Test, which did not contain performance counters as a data source.
The Azure Activity Log also showed that APPVM-2 had been disassociated from DCR-Prod and associated with DCR-Test around the relevant time.
The likely cause of the missing performance telemetry was therefore an incorrect DCR association rather than an AMA or Log Analytics failure.
The reason why the DCR association was changed would need to be investigated separately.

## Remediation

The VM was re-associated with the correct DCR containing the required performance counter configuration.

If the DCR association had been correct, the next troubleshooting steps would have included:

1.	Checking AMA status and logs.

2.	Verifying that the required performance counters were present in the DCR.

3.	Checking the locally downloaded DCR configuration.

4.	Checking AMA connectivity and related errors.

5.	Reinstalling AMA if required.

6.	Reconnecting the correct DCR.

7.	Verifying that performance telemetry resumed in Log Analytics.
   
## Verification

After restoring the correct DCR association, performance telemetry should be monitored to confirm that APPVM-2 resumes reporting performance data.

The final verification should compare APPVM-2 with the other VMs and confirm that:

•	Heartbeat continues to arrive.

•	Windows Events continue to arrive.

•	Performance telemetry has resumed.

•	The expected performance counters are being collected.

•	No further telemetry gaps are present.

## Troubleshooting Takeaway

A missing metric does not necessarily mean that the VM or Azure Monitor Agent is unavailable.
Comparing different telemetry types can narrow the investigation significantly. In this case, the continued arrival of heartbeat and Event data indicated that 
monitoring was partially functioning and directed the investigation towards the performance collection configuration and DCR.
The scenario also demonstrates the importance of checking DCR associations and configuration before reinstalling the monitoring agent.
