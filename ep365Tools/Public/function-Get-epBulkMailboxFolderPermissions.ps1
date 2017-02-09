function Get-epBulkMailboxFolderPermissions {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
    #>
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true)]
        [Array]$MailboxToProcess
    )
    BEGIN
    {
        Write-Verbose "Started running $($MyInvocation.MyCommand)"
        [string[]]$FolderExclusions = @("/Sync Issues","/Sync Issues/Conflicts","/Sync Issues/Local Failures","/Sync Issues/Server Failures","/Recoverable Items","/Deletions","/Purges","/Versions","/Calendar Logging")
 
    }
    PROCESS
    {
        Write-Verbose "Getting array of all mailbox folder permissions"
        Write-Verbose ("Mailbox: "+$MailboxToProcess.PrimarySMTPAddress)
 
        $FolderNames=$MailboxToProcess| Get-MailboxFolderStatistics | Where-Object {!($FolderExclusions -icontains $_.FolderPath)} |
                Select-Object -ExpandProperty FolderPath | ForEach-Object{$MailboxToProcess.DistinguishedName.ToString() +":"+($_ -replace ("/","\"))}
        $PermissionsList=@()
        Foreach ($FolderName in $FolderNames)
        {         
            Write-Verbose "Getting Permissions On $FolderName"
            $FolderName=$FolderName -replace ("Top Of Information Store","")
            $FolderPermissions=Get-MailboxFolderPermission -Identity $FolderName
            foreach ($FolderPermission in $FolderPermissions)
            {
                $PermissionsObject=New-Object -typename PSObject      
                $PermissionsObject | Add-Member -MemberType NoteProperty -Name "Identity" -Value ([string]$FolderName)                
                $PermissionsObject | Add-Member -MemberType NoteProperty -Name "User" -Value ([string]($FolderPermission.User.ToString()))
                [string[]]$AccessRightsStringArray=@()
                foreach ($Right in $FolderPermission.AccessRights)
                {
                    $AccessRightsStringArray+=$Right.ToString()
                }
                if ($AccessRightsStringArray.Count -eq 0)
                {
                    Write-Verbose "No Access Rights detected"
                    Continue
                }
                if ($AccessRightsStringArray.Count -eq 1)
                {
                    $AccessRightsString=$AccessRightsStringArray[0]
                }else
                {
                    $AccessRightsString=$AccessRightsStringArray -Join ","
                }
                $PermissionsObject | Add-Member -MemberType NoteProperty -Name "AccessRights" -Value ([string]$AccessRightsString)
                $PermissionsList+=$PermissionsObject
            }
        }
                $PermissionsList | Where-Object {!((($_.User -eq "Default") -or ($_.User -eq "Anonymous")) -and (($_.AccessRights -eq "None") -or ($_.AccessRights -eq 'AvailabilityOnly')))} 
    }
    END
    {
        Write-Verbose "Stopped running $($MyInvocation.MyCommand)"
    }  
}