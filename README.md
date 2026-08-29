# azure-monitor-vm-monitoring

Azure Monitor – VM Monitoring & Troubleshooting

Overview
This project demonstrates the use of Azure Monitor and Log Analytics to investigate common Azure VM monitoring and performance issues.
I created a small Azure environment consisting of Windows virtual machines connected to Azure Monitor using Azure Monitor Agent (AMA) and Data Collection Rules (DCRs). Telemetry is collected in a Log Analytics Workspace and investigated using Kusto Query Language (KQL).
The project focuses on a troubleshooting-oriented approach rather than simply collecting metrics. Each scenario is structured as a simulated support ticket and follows an investigation process from initial symptoms through telemetry analysis, correlation of multiple signals, findings and recommended next steps.

Troubleshooting Scenarios
1.	VM Unavailable / Unexpected Restart
Investigating VM availability, heartbeat gaps, resource pressure and Windows events.
2.	Disk Space Exhaustion
Investigating free disk space, disk performance and application write failures.
3.	Disk Performance Degradation
Investigating disk latency, queue length, I/O activity and application errors.
4.	Network / Connectivity Degradation
Investigating network traffic, packet errors, VM resource usage and determining when further investigation with Network Watcher or NSGs is required.
5.	VM Stopped Sending Performance Telemetry
Investigating missing Perf data while Heartbeat and Event telemetry continue to arrive, including AMA and DCR configuration.

Skills Demonstrated
•	Azure Monitor
•	Log Analytics Workspace
•	Azure Monitor Agent (AMA)
•	Data Collection Rules (DCR)
•	Kusto Query Language (KQL)
•	Windows performance counters
•	Windows Event Logs
•	Azure Activity Logs
•	VM troubleshooting
•	Telemetry troubleshooting
•	Correlation of multiple monitoring signals
•	Incident investigation and root-cause analysis
