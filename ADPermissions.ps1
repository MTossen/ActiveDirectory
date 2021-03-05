$FileCheck = Test-Path "C:\Users\$ENV:Username\Desktop\ADPermissions.csv"
If ($Filecheck) 
{
Remove-Item "C:\Users\$ENV:Username\Desktop\ADPermissions.csv"
}

Get-ADGroup -filter * -Properties SamAccountname, Description | Select SamAccountname, Description | 
Export-csv C:\Users\$ENV:Username\Desktop\ADGroups.csv -NoTypeInformation -Encoding UTF8
cls
Write-Host "Starting Export.. The script is estimated to take about 30 minutes to complete." -ForegroundColor Green
$ErrorActionPreference= 'silentlycontinue'

$csv = Import-csv C:\Users\$ENV:Username\Desktop\ADGroups.csv 
foreach ($row in $csv) {
    Get-ADGroupMember -Identity $row.SamAccountName |
        Get-ADUser -Properties * | Where {$_.ObjectClass -EQ "User"} | 
        Select-Object @{Name="Type";Expression={$_.ObjectClass}},
		    @{Name="Full name";Expression={$_.DisplayName}},
            @{Name="Username";Expression={$_.SamAccountName}},
            @{Name="Company";Expression={$_.Company}},
            @{Name="Department";Expression={$_.Department}},
            @{Name="Title";Expression={$_.Title}},
            @{Name="Manager";Expression={(Get-ADUser -property DisplayName $_.Manager).DisplayName}},
			@{Name="Managers username";Expression={(Get-ADUser -property SamAccountName $_.Manager).SamAccountname}},
			@{Name="Last logon date";Expression={(Get-ADUser -property LastLogonDate $_.SamAccountName).LastLogonDate}},
			@{Name="PWD changed";Expression={(Get-ADUser -property PasswordLastSet $_.SamAccountName).PasswordLastSet}},
            @{Name="Member of";Expression={$row.SamAccountName}},
            @{Name="Description";Expression={$row.Description}}			|
        
		Export-csv "C:\Users\$ENV:Username\Desktop\ADPermissions.csv" -NoTypeInformation -Encoding UNICODE -Append} 


Write-Host "Export completed" -ForegroundColor Green