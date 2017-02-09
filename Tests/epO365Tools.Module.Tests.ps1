$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$module = 'epAzureTools'

$moduleroot = "$here\..\$module"
$pvtFunction = "$moduleroot\Private"
$pubFunction = "$moduleroot\Public"
$testroot = $here

Describe -Tags ('Unit', 'Acceptance') "$module Module Tests"  {

  Context 'Module Setup' {
    It "has the root module $module.psm1" {
      "$moduleroot\$module.psm1" | Should Exist
    }

    It "has the a manifest file of $module.psm1" {
      "$moduleroot\$module.psd1" | Should Exist
      "$moduleroot\$module.psd1" | Should Contain "$module.psm1"
    }
    
    It '$module folder has public functions' {
      "$pubFunction\function-*.ps1" | Should Exist
    }

    It '$module folder has private functions' {
      "$pvtFunction\function-*.ps1" | Should Exist
    }

    It "$module is valid PowerShell code" {
      $psFile = Get-Content -Path "$moduleroot\$module.psm1" `
                            -ErrorAction Stop
      $errors = $null
      $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
      $errors.Count | Should Be 0
    }

  } # Context 'Module Setup'


  $functions = ((Get-ChildItem ..\ -Recurse -Exclude "*Tests.ps1") | Where-Object {$_.name -like "function-*"})
  $functionList = @() 
  ForEach ($function in $functions){
    $functionPath = $function.FullName
    $functionFileName = $function.basename
    $functionName = $function.Name.Substring(9)
  
    $functionObject = New-Object -TypeName psobject
    $functionObject | Add-Member -MemberType NoteProperty -Name "Path" -Value $functionPath
    $functionObject | Add-Member -MemberType NoteProperty -Name "FileName" -Value $functionFileName
    $functionObject | Add-Member -MemberType NoteProperty -Name "Name" -Value $FunctionName
  
    $functionList += $functionObject
  }

  foreach ($function in $functionList)
  {
      $function | Split-Path
    Context "Test Function $($function.Name)" {
      
      It "$($function.FileName) should exist" {
        "$($function.Path)" | Should Exist
      }
    
      It "$($function.FileName) should have help block" {
        "$($function.Path)" | Should Contain '<#'
        "$($function.Path)" | Should Contain '#>'
      }

      It "$($function.FileName) should have a SYNOPSIS section in the help block" {
        "$($function.Path)" | Should Contain '.SYNOPSIS'
      }
    
      It "$($function.FileName) should have a DESCRIPTION section in the help block" {
        "$($function.Path)" | Should Contain '.DESCRIPTION'
      }

      It "$($function.FileName) should have a EXAMPLE section in the help block" {
        "$($function.Path)" | Should Contain '.EXAMPLE'
      }
    
      It "$($function.FileName) should be an advanced function" {
        "$($function.Path)" | Should Contain 'function'
        "$($function.Path)" | Should Contain 'cmdletbinding'
        "$($function.Path)" | Should Contain 'param'
      }
      
      It "$($function.FileName) should contain Write-Verbose blocks" {
        "$($function.Path)" | Should Contain 'Write-Verbose'
      }
    
      It "$($function.FileName) should not contain Write-Host blocks" {
        "$($function.Path)" | Should not Contain 'Write-Host'
      }
    
      It "$($function.FileName) is valid PowerShell code" {
        $psFile = Get-Content -Path "$($function.Path)" `
                              -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
        $errors.Count | Should Be 0
      }

    
    } # Context "Test Function $function"

    Context "$($function.FileName) has tests" {
      It "$here\$($function.FileName).Tests.ps1 should exist" {
        "$here\$($function.FileName).Tests.ps1" | Should Exist
      }
    }
  
  } # foreach ($function in $functions)


}