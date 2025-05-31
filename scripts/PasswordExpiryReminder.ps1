# PowerShell Script: Password Expiry Reminder
# Description: Sends email reminders to users whose passwords expire in the next 7 days.

Import-Module ActiveDirectory

$daysUntilExpiry = 7
$users = Get-ADUser -Filter * -Properties "msDS-UserPasswordExpiryTimeComputed" | Where-Object {
    $_.Enabled -eq $true -and
    $_.UserPrincipalName -notlike "*@guest*" -and
    [datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed") -lt (Get-Date).AddDays($daysUntilExpiry)
}

foreach ($user in $users) {
    $expiryDate = [datetime]::FromFileTime($user."msDS-UserPasswordExpiryTimeComputed")
    $emailBody = @"
Hello $($user.Name),

🔐 Your password is set to expire on $expiryDate.

To change your password:
1. Visit your Microsoft profile: [My Sign-In Info Link]
2. Click 'Password' and follow the steps.

If you need help, contact IT Support.

"@
    Send-MailMessage -From "no-reply@yourdomain.com" -To $user.EmailAddress -Subject "Password Expiry Notice" -Body $emailBody -SmtpServer "smtp.yourdomain.com"
}
