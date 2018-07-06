#Requires -Version 3
Function Get-GosTimeService {

  <#
      .DESCRIPTION
        Gets the the Windows Time Service information from one or more running Windows operating systems using WinRM (PowerShell Remoting).
        Uses the words gos (as in guest operating system) but does not use PowerCLI. This is Windows only, but is great for vSphere admins
        to reach Windows guests and check time.

      .NOTES
        Script:  Get-GosTimeService.ps1
        Author:  Mike Nisk


  #>
  
  [CmdletBinding(DefaultParameterSetName='By ComputerName')]
  Param(
  
    #String. One or more Windows targets.
    [Parameter(Mandatory,Position=0,ParameterSetName = 'By ComputerName')]
    [Alias('Computer')]
    [string[]]$ComputerName,
    
    #PSCredential. The login to the Windows target. If not populated we use SSPI.
    [Parameter(Position=1,ParameterSetName='By ComputerName')]
    [Parameter(Position=1,ParameterSetName='By InputList')]
    [Alias('GuestCredential')]
    [PSCredential]$Credential,
    
    #String. Optionally, enter the path to a server list.
    [Parameter(Mandatory,Position=0,ParameterSetName = 'By InputList')]
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string]$InputList
  )
  
  Process {
    
    If($InputList){
      $Servers = Get-Content $InputList
    }
    Else{
      $Servers = $ComputerName
    }
    
    $Script:Report = @()
    Foreach($StrComputer in $Servers){
    
      ## Create runtime session
      If($Credential){
        
        ## Use Credential
        try{
          $session = New-PSSession $StrComputer -Credential $Credential -ErrorAction Stop
        }
        catch{
          
          ## Explain error if possible
          $strError = $Error.exception.Message | Out-String
          [bool]$timeIssue = {
            If($strError | Select-String kerberos){
              return $true
            }
            else{
              return $false
            }
          }
          
          If($timeIssue){
            ## we are easily fooled here by other issues but...
            Write-Warning -Message ('Skipping {0} due to bad timesync!' -f $StrComputer)
          }
          Else{
            Write-Warning -Message ('Cannot connect to {0}' -f $StrComputer)
          }
          Continue
        }
      }
      Else{
        ## Use SSPI
        try{
          $session = New-PSSession $StrComputer -ErrorAction Stop
        }
        catch{
          
          ## Explain error if possible
          $strError = $Error.exception.Message | Out-String
          [bool]$timeIssue = {
            If($strError | Select-String kerberos){
              return $true
            }
            else{
              return $false
            }
          }
          
          If($timeIssue){
            Write-Warning -Message ('Skipping {0} due to bad timesync!' -f $StrComputer)
          }
          Else{
            Write-Warning -Message ('Cannot connect to {0}' -f $StrComputer)
          }
          Continue
        }
      }
      
      ## Use WinRM and Get-TimeZone
      $info = Invoke-Command -Session $session -ScriptBlock {
        
        ## Computername
        [string]$PSComputerName = $env:COMPUTERNAME
        
        ## Get local time on guest
        $sysLocalTime = Get-Date
        
        ## Handle DST
        [bool]$DstActive = $sysLocalTime.IsDaylightSavingTime()
        
        ## Handle w32time service info
        $w32 = Get-Service -Name W32Time
        $w32Status = $w32.status
        $w32StartType = $w32.StartType
        
        ## Populate object
        $detail = [PSCustomObject]@{
          PSComputerName  = $PSComputerName
          Time            = $sysLocalTime
          w32Status       = $w32Status
          w32StartType    = $w32StartType
          'DST Active'    = $DstActive
        }
        
        ## return to upstream info object
        return $detail
      }
      
      ## Add to report
      If($info){
        $Script:Report += $info
      }
      
      ## Session cleanup
      If($session){
        $null = Remove-PSSession -Session $session -Confirm:$false -ErrorAction Ignore -WarningAction Ignore
      }
    }
    ## return output
    return $Script:Report
  }
}