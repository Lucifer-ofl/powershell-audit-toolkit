# PowerShell Script: Password Expiry Report
# Description: Generates a CSV report of users with passwords expiring in the next 15 days.

Import-Module ActiveDirectory

$daysUntilExpiry = 15
$reportPath = "C:\Reports\PasswordExpiryReport.csv"
$expiryList = @()

$users = Get-ADUser -Filter * -Properties "msDS-UserPasswordExpiryTimeComputed" | Where-Object {
    $_.Enabled -eq $true -and
    $_.UserPrincipalName -notlike "*@guest*" -and
    [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") -lt (Get-Date).AddDays($daysUntilExpiry)
}

foreach ($user in $users) {
    $expiryList += [PSCustomObject]@{
        Name        = $user.Name
        Username    = $user.SamAccountName
        ExpiryDate  = [datetime]::FromFileTime($user."msDS-UserPasswordExpiryTimeComputed")
        Email       = $user.EmailAddress
    }
}

$expiryList | Export-Csv -Path $reportPath -NoTypeInformation
