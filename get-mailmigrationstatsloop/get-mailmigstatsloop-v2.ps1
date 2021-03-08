###Created:Nov 26 2015###
###Modified:Mar 08 2021###
###Author:Kristopher Roy###
###Company:Belltechlogix###

#Check if Session is Open
If($session.State -ne "Opened")
{
    $UserCredential = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection 
    Import-PSSession $Session
}

$BatchID = "nameofthebatch"

#create Do-While loop = less than 100%
Do{
    $all = Get-MigrationUser -BatchID $BatchID|Get-MigrationUser|Get-MoveRequestStatistics|select DisplayName,PercentComplete,StatusDetail,TotalMailboxSize,CompleteAfter
    $count = $all.percentcomplete.count
    $percentdone = [math]::Round(($all.percentcomplete -split ' '  | measure-object -sum).sum/$count,2)
    Write-Progress -Activity ("migration completion") -Status "Total percent of $($count) mailboxes $percentdone%" -PercentComplete (($all.percentcomplete -split ' '  | measure-object -sum).sum/$count)
    $complete = $all|where{$_.StatusDetail -like "Completed"}
    $all|format-table
    write-host $complete.count" Out of "$all.count "$BatchID" " Finalized"
    sleep 10
}while($percentdone -lt 100)
#change the percentdone number to 95 if you just want to verify seeding