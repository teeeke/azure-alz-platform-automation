# Bootstrap script for Azure Landing Zone
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$TenantId,
    
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $true)]
    [string]$Location,
    
    [Parameter(Mandatory = $false)]
    [string]$ConfigPath = ".\config\bootstrap-config.yml",
    
    [Parameter(Mandatory = $false)]
    [string]$ManagementGroupPrefix = "alz"
)

function Test-Prerequisite {
    [CmdletBinding()]
    param()

    Write-Verbose "Checking prerequisites..."
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        throw "PowerShell 7 or higher is required"
    }
    
    # Check required modules
    $requiredModules = @('Az.Accounts', 'Az.Resources', 'Az.ManagementGroups')
    foreach ($module in $requiredModules) {
        if (!(Get-Module -ListAvailable -Name $module)) {
            throw "Required module $module is not installed"
        }
    }
    
    # Check if config file exists
    if (!(Test-Path $ConfigPath)) {
        throw "Configuration file not found at $ConfigPath"
    }
    
    Write-Host "All prerequisites met!" -ForegroundColor Green
}

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
