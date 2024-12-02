# Add-SecurityGroupMembers.ps1
# Script to manage Azure AD security group memberships
# Requirements: Microsoft.Graph PowerShell module

#Requires -Modules Microsoft.Graph.Users, Microsoft.Graph.Groups
#Requires -Version 5.1

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$CsvPath,
    
    [Parameter(Mandatory = $false)]
    [string]$UserPrincipalName,
    
    [Parameter(Mandatory = $true)]
    [string]$GroupName,
    
    [Parameter(Mandatory = $false)]
    [string]$LogPath = ".\SecurityGroupAddLog.txt"
)

function Write-Log {
    param($Message)
    
    $LogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    Write-Verbose $LogMessage
    Add-Content -Path $LogPath -Value $LogMessage
}

function Connect-ToGraph {
    try {
        # Check if already connected
        $context = Get-MgContext
        if (-not $context) {
            Write-Log "Connecting to Microsoft Graph..."
            Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All"
            Select-MgProfile -Name "beta"
        }
        return $true
    }
    catch {
        Write-Log "Error connecting to Microsoft Graph: $_"
        return $false
    }
}

function Add-UserToGroup {
    param (
        [string]$UserPrincipalName,
        [string]$GroupId
    )
    
    try {
        $user = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'"
        if (-not $user) {
            Write-Log "User not found: $UserPrincipalName"
            return $false
        }
        
        New-MgGroupMember -GroupId $GroupId -DirectoryObjectId $user.Id
        Write-Log "Successfully added $UserPrincipalName to group"
        return $true
    }
    catch {
        Write-Log "Error adding $UserPrincipalName to group: $_"
        return $false
    }
}

# Main script execution
try {
    # Initialize log file
    if (-not (Test-Path $LogPath)) {
        New-Item -Path $LogPath -ItemType File -Force | Out-Null
    }
    
    Write-Log "Script started"
    
    # Connect to Microsoft Graph
    if (-not (Connect-ToGraph)) {
        throw "Failed to connect to Microsoft Graph"
    }
    
    # Get the target security group
    $group = Get-MgGroup -Filter "displayName eq '$GroupName'"
    if (-not $group) {
        throw "Security group '$GroupName' not found"
    }
    
    # Process users based on input method
    if ($CsvPath) {
        if (-not (Test-Path $CsvPath)) {
            throw "CSV file not found: $CsvPath"
        }
        
        Write-Log "Processing users from CSV: $CsvPath"
        $users = Import-Csv $CsvPath
        
        foreach ($user in $users) {
            if (-not $user.UserPrincipalName) {
                Write-Log "Warning: Missing UserPrincipalName in CSV row"
                continue
            }
            
            $result = Add-UserToGroup -UserPrincipalName $user.UserPrincipalName -GroupId $group.Id
            if ($result) {
                Write-Host "Successfully added $($user.UserPrincipalName) to $GroupName" -ForegroundColor Green
            }
            else {
                Write-Host "Failed to add $($user.UserPrincipalName) to $GroupName" -ForegroundColor Red
            }
        }
    }
    elseif ($UserPrincipalName) {
        Write-Log "Processing single user: $UserPrincipalName"
        $result = Add-UserToGroup -UserPrincipalName $UserPrincipalName -GroupId $group.Id
        if ($result) {
            Write-Host "Successfully added $UserPrincipalName to $GroupName" -ForegroundColor Green
        }
        else {
            Write-Host "Failed to add $UserPrincipalName to $GroupName" -ForegroundColor Red
        }
    }
    else {
        throw "Either CsvPath or UserPrincipalName must be provided"
    }
}
catch {
    Write-Log "Critical error: $_"
    Write-Host "An error occurred. Check the log file at $LogPath for details." -ForegroundColor Red
    throw $_
}
finally {
    Write-Log "Script completed"
}