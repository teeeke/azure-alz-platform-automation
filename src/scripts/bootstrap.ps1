# PowerShell script to bootstrap Azure Landing Zone automation

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TenantId,
    
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $true)]
    [string]$Location,
    
    [Parameter(Mandatory = $false)]
    [string]$ManagementGroupPrefix = "alz"
)

# Import required modules
Import-Module Az.Accounts
Import-Module Az.Resources

# Connect to Azure
try {
    Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId
}
catch {
    Write-Error "Failed to connect to Azure: $_"
    exit 1
}

# Create Management Group Structure
function Create-ManagementGroupStructure {
    param (
        [string]$Prefix
    )
    
    try {
        # Create root management group
        New-AzManagementGroup -GroupName "$Prefix-root" -DisplayName "ALZ Root"
        
        # Create platform management group
        New-AzManagementGroup -GroupName "$Prefix-platform" -DisplayName "Platform" -ParentId "/providers/Microsoft.Management/managementGroups/$Prefix-root"
        
        Write-Output "Management group structure created successfully"
    }
    catch {
        Write-Error "Failed to create management group structure: $_"
        exit 1
    }
}

# Main execution
try {
    Write-Output "Starting Azure Landing Zone bootstrap process..."
    
    # Create management group structure
    Create-ManagementGroupStructure -Prefix $ManagementGroupPrefix
    
    Write-Output "Bootstrap process completed successfully"
}
catch {
    Write-Error "Bootstrap process failed: $_"
    exit 1
}
