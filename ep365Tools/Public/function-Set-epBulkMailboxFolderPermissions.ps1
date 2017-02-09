function Set-epBulkMailboxFolderPermissions {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
    #>
    [CmdletBinding()]
    Param (
    
    [parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [PSobject]$FolderObject
    
    )

    PROCESS
    {

        Set-MailboxFolderPermission -Identity $_.identity -user $_.user -AccessRights $_.accessrights 

    }
}