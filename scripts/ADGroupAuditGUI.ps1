# PowerShell Script: AD Group Membership Audit GUI
# Description: GUI-based tool to audit AD group membership with threaded scanning.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form
$form.Text = "AD Group Audit Tool"
$form.Size = New-Object Drawing.Size(600,400)

$startButton = New-Object Windows.Forms.Button
$startButton.Text = "Start Audit"
$startButton.Location = New-Object Drawing.Point(20,20)
$form.Controls.Add($startButton)

$resultsBox = New-Object Windows.Forms.TextBox
$resultsBox.Multiline = $true
$resultsBox.ScrollBars = "Vertical"
$resultsBox.Size = New-Object Drawing.Size(550,280)
$resultsBox.Location = New-Object Drawing.Point(20,60)
$form.Controls.Add($resultsBox)

$startButton.Add_Click({
    $resultsBox.AppendText("Starting audit...`r`n")

    $scriptBlock = {
        Import-Module ActiveDirectory
        $groups = Get-ADGroup -Filter * | Where-Object { $_.Name -notlike "*_GUEST*" }

        foreach ($group in $groups) {
            $members = Get-ADGroupMember -Identity $group.Name | Select-Object Name, SamAccountName
            foreach ($member in $members) {
                "$($group.Name): $($member.SamAccountName)" 
            }
        }
    }

    $job = Start-Job -ScriptBlock $scriptBlock
    Wait-Job $job
    $output = Receive-Job $job
    $resultsBox.Lines = $output
})

$form.ShowDialog()
