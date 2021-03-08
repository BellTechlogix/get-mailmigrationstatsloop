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

#set loop count to 0
$count = 0

#create Do-While loop
Do{
    #If you want to check statuses for multiple batches copy and paste everything from batchid down to end of loop, do not copy $count++ 
    
    #Add 1 to count for loop
    $count++
    #Manually change your batch ID before run
    $batchid = "01102018"
    Write-Host "Status for Batch"$batchid"....." -ForegroundColor Green
    $mig = Get-MigrationUser -BatchID $batchid|Get-MoveRequestStatistics|select *
	
	#this code creates a status bar
	$count = $mig.percentcomplete.count
    $percentdone = [math]::Round(($mig.percentcomplete -split ' '  | measure-object -sum).sum/$count,2)
    Write-Progress -Activity ("migration completion") -Status "Total percent of $($count) mailboxes $percentdone%" -PercentComplete (($mig.percentcomplete -split ' '  | measure-object -sum).sum/$count)

    #uncomment the next line when checking for syncing stats
    #$mig|where{$_.PercentComplete -ilt 95}|select DisplayName,StatusDetail,TotalMailboxSize,PercentComplete,LastSuccessfulSyncTimestamp|sort-object PercentComplete -Descending|ft    
    
    #uncomment the next line when checking if Sync date is not date you say, and edit the date in the line
    #$mig|where{$_.PercentComplete -ilt 100 -and $_.LastSuccessfulSyncTimestamp -ilt "1/10/2018"}|select DisplayName,StatusDetail,TotalMailboxSize,PercentComplete,LastSuccessfulSyncTimestamp|sort-object PercentComplete -Descending|ft
    
    #uncomment the next line when checking for finalization stats
    #$mig|where{$_.PercentComplete -ilt 100}|select DisplayName,StatusDetail,TotalMailboxSize,PercentComplete,LastSuccessfulSyncTimestamp|sort-object PercentComplete -Descending|ft
    
    #gets statuses and loops to write current numbers
    $statustypes = $mig|select StatusDetail|Sort-Object -Property StatusDetail -Unique
    $statuses = $mig|select StatusDetail,PercentComplete
    FOREACH($type in $statustypes)
    {
        write-host $type.StatusDetail ($statuses|where{$_.StatusDetail -eq $type.StatusDetail -and ($_.StatusDetail).count -gt 0 -and ($_.StatusDetail).count -inotlike " "}).statusdetail.count" of "$mig.count
    }
    write-host "`n"
}
#change the number to loop as many times as you wish
while($count -lt 30)