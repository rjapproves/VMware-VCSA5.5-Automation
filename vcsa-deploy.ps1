Add-PSSnapin Vmware.vimautomation.core
 
 $xml = [XML](Get-Content vcsaconfig.xml)
 
 $vcsahostname = $xml.MasterConfig.config.vcsahostname
 $rootpassword = $xml.MasterConfig.Config.rootpassword
 $VMnetwork = $xml.Masterconfig.config.MgmtNetwork
 $vcsadns = $xml.Masterconfig.config.vcsadns
 $vcsagateway = $xml.Masterconfig.config.vcsagateway
 $vcsaip = $xml.Masterconfig.config.vcsaip
 $vcsanetmask = $xml.Masterconfig.config.vcsanetmask
 $ClusterName = $xml.Masterconfig.config.clustername
 $vcsalocation = $xml.Masterconfig.config.vcsalocation
 $vcenter = $xml.Masterconfig.vcenterconfig.vcenter
 $vcenteruser = $xml.Masterconfig.vcenterconfig.vcusername
 $vcenterpassword = $xml.Masterconfig.vcenterconfig.vcpassword
 
 #Ignore selfsigned cert
 [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
 
 #Connect to the vcenter where vSM will be deployed
 Write-host "Connecting to vcenter..."
 connect-viserver -server $vcenter -protocol https -username $vcenteruser -password $vcenterpassword | Out-Null
 
 
 #Identify the right cluster and host to deploy vsm
 $VMhost = Get-Cluster $ClusterName | Get-VMHost | Sort MemoryGB | Select -first 1
 $datastore = $VMhost | Get-Datastore | Sort FreeSpaceGB -Descending | Select -first 1
 $Network = Get-VirtualPortgroup -Name $VMnetwork -VMHost $VMhost
 
 #Load the ovf specific configuration in the $ovfconfig file
 $ovfconfig = Get-OvfConfiguration $vcsalocation
 
 #Populate the members properties of the ovf file.
 $ovfconfig.common.vami.hostname.Value = $vcsahostname
 $ovfconfig.IpAssignment.IpProtocol.Value = 'IPv4'
 $ovfconfig.NetworkMapping.Network_1.Value = $VMnetwork
 $ovfconfig.vami.VMware_vCenter_Server_Appliance.DNS.Value = $vcsadns
 $ovfconfig.vami.VMware_vCenter_Server_Appliance.gateway.Value = $vcsagateway
 $ovfconfig.vami.VMware_vCenter_Server_Appliance.ip0.Value = $vcsaip
 $ovfconfig.vami.VMware_vCenter_Server_Appliance.netmask0.Value = $vcsanetmask
 
 #Importing the vapp now
 Write-host "Importing vApp..."
 Import-vapp -Source $vcsalocation -OVFConfiguration $ovfconfig -Name $vcsahostname -VMHost $VMhost -Datastore $datastore -Diskstorageformat thin
 
 #Optional - Setting memory to 16gb..
 #Set-vm -vm $vcsahostname -memorygb 16 -confirm:$false
 
 #Poweron the vm
 Write-Host "Powering on vShield vm... and waiting for tools"
 Start-vm $vcsahostname | Wait-Tools
 
 #Configuring VCSA appliance now..
 Write-Host "Configuring vcsa appliance now.."
 Invoke-VMScript -VM $vcsahostname -ScriptText "/usr/sbin/vpxd_servicecfg eula accept && /usr/sbin/vpxd_servicecfg db write embedded && /usr/sbin/vpxd_servicecfg sso write embedded && /usr/sbin/vpxd_servicecfg service start && /usr/sbin/vpxd_servicecfg timesync write ntp time.rackspace.com" -ScriptType Bash -GuestUser 'root' -GuestPassword 'vmware'
 sleep(30)
 Invoke-VMScript -VM $vcsahostname -ScriptText "echo ${rootpassword}|passwd root --stdin" -ScriptType Bash -GuestUser "root" -GuestPassword "vmware" -ErrorAction SilentlyContinue
 Restart-VMGuest -VM $vcsahostname -Confirm:$false 
 Write-Host "The guest configuration is now complete and it is restarting.. please wait a few minutes before all services are started..."
