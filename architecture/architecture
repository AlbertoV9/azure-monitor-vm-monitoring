Architecture
This is a simple architecture whose purpose is to generate telemetry data for Azure Monitor troubleshooting scenarios.
Four Windows VMs were used to provide multiple independent telemetry sources and allow comparison between affected and healthy instances during investigations. The VMs are organized into two Web and two App instances.
Azure Monitor Agent (AMA) is installed on the VMs and configured through a Data Collection Rule (DCR). The DCR defines the telemetry to be collected and sends the data to a Log Analytics Workspace.
The collected telemetry is queried and analyzed in Log Analytics using Kusto Query Language (KQL).
A broad set of performance counters and Windows Events was collected to provide sufficient telemetry for the troubleshooting scenarios.
In a production environment, telemetry selection would be reviewed against diagnostic requirements, ingestion volume, retention requirements, and cost.
