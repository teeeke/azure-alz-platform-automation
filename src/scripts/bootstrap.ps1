# Bootstrap script for Azure Landing Zone
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Azure AD Tenant ID")]
    [string]$TenantId,

    [Parameter(Mandatory = $true, HelpMessage = "Azure Subscription ID")]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true, HelpMessage = "Azure Region for resource deployment")]
    [ValidateSet('eastus', 'eastus2', 'westus', 'westus2', 'centralus')]
    [string]$Location,

    [Parameter(Mandatory = $false, HelpMessage = "Path to YAML configuration file")]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$ConfigPath = ".\config\bootstrap-config.yml",

    [Parameter(Mandatory = $false, HelpMessage = "Prefix for management group hierarchy")]
    [ValidatePattern('^[a-zA-Z0-9-]{1,10}$')]
    [string]$ManagementGroupPrefix = "alz"
)

# Initialize script-level variable for config
$script:ALZConfig = $null
$script:ConfigPath = $null

#Requires -Version 7.0
#Requires -Modules Az.Accounts, Az.Resources, Az.ManagementGroups

function Test-Prerequisite {
    [CmdletBinding()]
    param()
    Write-Verbose "Checking prerequisites..."
    try {
        $config = Get-Content -Path $script:ConfigPath -Raw | ConvertFrom-Yaml
        Write-Verbose "Configuration file parsed successfully"
        $script:ALZConfig = $config
        $requiredSections = @('azure', 'managementGroups', 'logging', 'networking')
        $missingSections = $requiredSections.Where({ -not $config.ContainsKey($_) })
        if ($missingSections) {
            throw "Missing required configuration sections: $($missingSections -join ', ')"
        }
        Write-Information "Configuration validation completed" -InformationAction Continue
    }
    catch {
        throw "Configuration validation failed: $_"
    }
}

function Connect-ToAzure {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TenantId,
        [Parameter(Mandatory = $true)]
        [string]$SubscriptionId
    )
    Write-Verbose "Initiating Azure connection..."
    try {
        $null = Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId -ErrorAction Stop
        $context = Set-AzContext -Subscription $SubscriptionId -ErrorAction Stop
        Write-Verbose "Connected to subscription: $($context.Subscription.Name)"
        Write-Information "Azure connection established" -InformationAction Continue
    }
    catch {
        throw "Azure connection failed: $_"
    }
}

function New-ManagementGroupStructure {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Prefix,
        [Parameter(Mandatory = $true)]
        [string]$Location
    )
    Write-Verbose "Creating management group hierarchy..."
    try {
        # Create root management group
        $rootParams = @{
            GroupName = "$Prefix-root"
            DisplayName = "ALZ Root"
            Location = $Location
            ErrorAction = "Stop"
        }
        if ($PSCmdlet.ShouldProcess("$Prefix-root", "Create root management group")) {
            $rootGroup = New-AzManagementGroup @rootParams
            Write-Verbose "Created root management group: $($rootGroup.Name)"
        }

        # Create platform hierarchy
        $groups = @(
            @{ Name = 'platform'; Display = 'Platform'; Parent = $rootGroup.Name }
            @{ Name = 'identity'; Display = 'Identity'; Parent = "$Prefix-platform" }
            @{ Name = 'management'; Display = 'Management'; Parent = "$Prefix-platform" }
            @{ Name = 'connectivity'; Display = 'Connectivity'; Parent = "$Prefix-platform" }
            @{ Name = 'landingzones'; Display = 'Landing Zones'; Parent = $rootGroup.Name }
            @{ Name = 'corp'; Display = 'Corporate'; Parent = "$Prefix-landingzones" }
            @{ Name = 'online'; Display = 'Online'; Parent = "$Prefix-landingzones" }
            @{ Name = 'sandbox'; Display = 'Sandbox'; Parent = $rootGroup.Name }
            @{ Name = 'decommissioned'; Display = 'Decommissioned'; Parent = $rootGroup.Name }
        )

        foreach ($group in $groups) {
            $mgParams = @{
                GroupName = "$Prefix-$($group.Name)"
                DisplayName = $group.Display
                ParentId = "/providers/Microsoft.Management/managementGroups/$($group.Parent)"
                Location = $Location
                ErrorAction = "Stop"
            }
            if ($PSCmdlet.ShouldProcess("$Prefix-$($group.Name)", "Create management group")) {
                $mg = New-AzManagementGroup @mgParams
                Write-Verbose "Created management group: $($mg.Name)"
            }
        }
        Write-Information "Management group hierarchy created" -InformationAction Continue
    }
    catch {
        throw "Failed to create management group structure: $_"
    }
}

# Main execution
try {
    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'
    $VerbosePreference = 'Continue'

    # Start transcript
    $transcriptPath = Join-Path $PSScriptRoot "logs"
    if (-not (Test-Path $transcriptPath)) {
        $null = New-Item -ItemType Directory -Path $transcriptPath
    }
    $logFile = Join-Path $transcriptPath "bootstrap_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    Start-Transcript -Path $logFile

    Write-Information "Starting Azure Landing Zone bootstrap process..." -InformationAction Continue

    # Store ConfigPath in script scope for use in Test-Prerequisite
    $script:ConfigPath = $ConfigPath

    # Run deployment steps
    Test-Prerequisite
    Connect-ToAzure -TenantId $TenantId -SubscriptionId $SubscriptionId
    New-ManagementGroupStructure -Prefix $ManagementGroupPrefix -Location $Location

    Write-Information "Bootstrap process completed successfully!" -InformationAction Continue
}
catch {
    Write-Error "Bootstrap process failed: $_"
    Write-Error $_.ScriptStackTrace
    exit 1
}
finally {
    Stop-Transcript
}
