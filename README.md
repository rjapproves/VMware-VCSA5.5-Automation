VMware-VCSA5.5-Automation
=========================

++++++ Notice == Script tested on ESXi 5.5 running vCenter 5.5 Update 2. No guarantees. Ensure you run it on test environment before executing in production. Author of this script assumes ZERO liability. ++++++

Introduction
============

The Script allows you to deploy vCenter Server Appliance to a vCenter in a nested environment and also configures it with the vCenter.

It uses Powershell+PowerCLI to deploy the vCenter Server Appliance and configures it with IP.

Prerequisites
============

VCSA Appliance OVA File.
Powershell version 4.0
PowerCli version 5.8 Release 1
Network able to access vCenter

a. vcsaconfig.xml b. vcsa-deploy.ps1

Execution Method
============

Follow the below steps to properly execute the file.

1. Ensure vcsaconfig.xml and vcsa-deploy.ps1 are in the same folder.
2. Populate vcsaconfig.xml with all the info as per your vcenter and vshield info. This allows you to configure your inputs before you execute the script.
3. Execute the script once vcsaconfig.xml is configured.

Contents
========

vcsaConfig.xml

```<?xml version="1.0"?>
<MasterConfig>
<vcenterconfig>
<vcenter>TOP LEVEL VCENTER WHERE VCSA WILL BE DEPLOYED INTO</vcenter>
<vcusername>administrator@vsphere.local</vcusername>
<vcpassword>VCENTER PASSWORD</vcpassword>
</vcenterconfig>

<Config>
<vcsahostname>VCSA HOST NAME</vcsahostname>
<rootpassword>NEW ROOT PASSWORD</rootpassword>
<MgmtNetwork>VCSA NETWORK</MgmtNetwork>
<vcsadns>DNS1,DNS2</vcsadns>
<vcsagateway>GATEWAY</vcsagateway>
<vcsaip>VCSA IP</vcsaip>
<vcsanetmask>NETMASK</vcsanetmask>
<clustername>TARGET CLUSTER</clustername>
<vcsalocation>Location of VCSA.OVA COMPLETE PATH</vcsalocation>

</MasterConfig>
```

