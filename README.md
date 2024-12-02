# Azure AD Security Group Management Script

This PowerShell script helps manage Azure AD security group memberships using the Microsoft Graph API. It supports both single user additions and bulk operations using a CSV file.

## Prerequisites

- PowerShell 5.1 or later
- Microsoft.Graph PowerShell modules:
  - Microsoft.Graph.Users
  - Microsoft.Graph.Groups
- Appropriate Azure AD permissions:
  - User.ReadWrite.All
  - Group.ReadWrite.All

## Installation

1. Install required PowerShell modules:
```powershell
Install-Module Microsoft.Graph.Users
Install-Module Microsoft.Graph.Groups
```

2. Download the script to your local machine.

## Usage

### Adding a Single User

```powershell
.\Add-SecurityGroupMembers.ps1 -UserPrincipalName "user@domain.com" -GroupName "Security Group Name"
```

### Adding Multiple Users from CSV

1. Create a CSV file with a column named "UserPrincipalName"
2. Run the script:
```powershell
.\Add-SecurityGroupMembers.ps1 -CsvPath ".\users.csv" -GroupName "Security Group Name"
```

### Optional Parameters

- `-LogPath`: Specify a custom path for the log file (default: .\SecurityGroupAddLog.txt)
- `-Verbose`: Enable verbose output

## Features

- Automatic connection to Microsoft Graph
- Error handling and logging
- Support for both single user and bulk operations
- Detailed logging of all operations
- Colored console output for operation status