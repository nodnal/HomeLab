# HomeLab
Notes on setting up my windows lab

## Virtual Machines

### DC1

`SConfig` used to setup:

* Network Adapter
    * IP: 192.168.1.100
    * DNS 1: 192.168.1.100
    * DNS 2: none
* Hostname 
  * DC1

#### Installing AD Service

```shell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools 
```
```shell
Import-Module ADDSDeployment
Install-ADDSForest
```

Domain name: abc.local


### Managment Client

Enable WinRM Service:

`Start-Service WinRM`

Add DC1 to Trusted hosts for Remote PSSession:

`set-item WSMan:\localhost\Client\TrustedHosts -value 192.168.1.100`



### PFSense

#### Network Config

*LAN Adapter*
* LabLAN - virtual switch
* IP: 192.168.1.1
* DHCP
  * range: 192.168.1.100 - 192.168.1.200
  * Gateway: 192.168.1.1
  * 
*WAN Adapter*
* LabWAN - virtual switch
* IP: DHCP