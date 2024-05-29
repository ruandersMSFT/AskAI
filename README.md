# Authenticate to your Azure account (if not already done)
Connect-AzAccount

# Get all subscriptions
$subs = Get-AzSubscription

# Loop through each subscription
foreach ($sub in $subs) {
    # Display the current processing subscription
    Write-Host "Processing subscription $($sub.Name)"

    try {
        # Select the subscription
        Select-AzSubscription -SubscriptionId $sub.SubscriptionId -ErrorAction Continue

        # Get all VMs information
        $vms = Get-AzVm

        # Loop through all the VMs
        foreach ($vm in $vms) {
            $vmName = $vm.Name
            $resourceGroupName = $vm.ResourceGroupName

            # Check if the VM is backed up
            $backupStatus = (Get-AzRecoveryServicesBackupStatus -Name $vmName -ResourceGroupName $resourceGroupName -Type AzureVM).BackedUp

            if ($backupStatus) {
                Write-Host "VM '$vmName' in resource group '$resourceGroupName' is backed up."
            } else {
                Write-Host "VM '$vmName' in resource group '$resourceGroupName' is not backed up."
            }
        }
    } catch {
        Write-Host $error[0]
    }
}
