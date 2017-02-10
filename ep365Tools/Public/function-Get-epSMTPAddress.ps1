function Get-epSMTPAddress {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .EXAMPLE
    #>
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)][Array]$Recipient
    )

    Process
    {
        $PrimarySMTP = $Null
        $UserObject = Get-ADUser $_ -Properties ProxyAddresses
        $ProxyAddressOutput = @()
        Write-Verbose "$($UserObject.Name) has $($UserObject.ProxyAddresses.Count) proxy addresses"
        ForEach ($ProxyAddress in $UserObject.ProxyAddresses){
            
            $SMTPAddress = $ProxyAddress.Substring(5)
            Write-Verbose "Processing SMTPAddress: $SMTPAddress"

            If ($ProxyAddress.Substring(0,4) -cmatch "SMTP"){
                $PrimarySMTP = $True
                Write-Verbose "$SMTPAddress is the Primary SMTP Address"
            } #else {
              #  $PrimarySMTP = $Null
            #} 

            $ProxyAddresses = New-Object -TypeName PSObject
            $ProxyAddresses | Add-Member -MemberType NoteProperty -Name "SMTPAddress" -Value $SMTPAddress
            $ProxyAddresses | Add-Member -MemberType NoteProperty -Name "isPrimary" -Value $PrimarySMTP

            $ProxyAddressOutput += $ProxyAddresses

            
        }
        
        Return $ProxyAddressOutput
    }
}