# Cluster Capacity
This dashboard reports on the vailability of CPU and Memory based on the region of the server: 
- App Servers: Used for all tenant workloads (ie. non-infrastructure)
- Infra Servers: Used for all shared services related to platform operations
- Master Servers: Used for OpenShift schedulers, no additional workloads are scheduled here. 

## App Servers
Monitoring App servers provides a real-time view into the requested and allocated resources
for servers that run user workloads. This dashboard should be consulted when a new project 
or team is onboard that requires resources. 

### 