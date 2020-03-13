<# Comprehensive Update Script #>

<#

 Author: RWG
 31 Jan 2020

 -> Purpose: Automated update of Mission Planning Systems

 #>

 $ErrorActionPreference = "SilentlyContinue"

function UpdateDAFIF
{
    Write-Host -ForegroundColor Yellow "[*] Beginning DAFIF update routine "

    $currentPath = Get-Location

    $dafifDirectory = Join-Path -Path $currentPath -ChildPath "\DAFIF\"

    Write-Host -ForegroundColor Yellow "[*] Checking for the presence of the DAFIF Utility..." 
    
    $pathTest = Test-Path -Path "C:\Program Files (x86)\PFPS\system\DafifCommand.exe"
    
    if($pathTest)
    {
        Write-Host -ForegroundColor Green "[*] Located DAFIF Utility "

        $ts = TimeStamp ; Logger "[*] DAFIF utility located at: $ts `n "
    }
    else
    {
        $ts = TimeStamp ; Logger "[!] Failed to locate DAFIF Utility at: $ts `n "

        Write-Host -ForegroundColor Red "[!] Failed to locate DAFIF Utility [!]" ; return
    }

    Write-Host -ForegroundColor Yellow "[*] Checking for the presence of new DAFIF data... "

    $dataTest = Test-Path -Path $dafifDirectory

    if($dataTest)
    {
        Write-Host -ForegroundColor Green "[*] Located DAFIF Data Directory "

        $ts = TimeStamp ; Logger "[*] Located DAFIF Data Directory at: $ts `n "

        try
        {
             Write-Host -BackgroundColor Gray -ForegroundColor Yellow "[*] Removing previous DAFIF Directories ..."

             Get-ChildItem -Path "C:\" | Foreach-Object { if($_.Name -eq "DAFIF" -or $_.Name -like "DAFIF") { Remove-Item -Path $_.FullName -Recurse -Force -Verbose } }

             $ts = TimeStamp ; Logger "[*] Removed previous DAFIF directories at: $ts `n "
        }
        catch
        {
            Write-Host -ForegroundColor Red "[!] Failed to remove previous DAFIF [!]"

            $ts = TimeStamp ; Logger "[!] Failed to remove previous DAFIF at: $ts `n "
        }
        try
        {
             Write-Host -ForegroundColor Green "[*] Copying DAFIF to system root ..."

             Copy-Item -Path $dafifDirectory -Force -Recurse -Verbose -Destination "C:\"

             $ts = TimeStamp ; Logger "[*] Copied DAFIF to system root at: $ts `n "
        }
        catch
        {
            Write-Host -ForegroundColor Red "[!] Failed to copy DAFIF to system root [!]"

            $ts = TimeStamp ; Logger "[!] Failed to copy DAFIF to system root at: $ts `n "
        }
    }
    else
    {
        $ts = TimeStamp ; Logger "[!] Failed to locate DAFIF Data at: $ts `n "

        Write-Host -ForegroundColor Red "[!] Failed to locate DAFIF data [!]" ; return
    }

    Write-Host -ForegroundColor Yellow "[*] Attempting DAFIF data import operation ..." ; 

    try
    {
        Set-Location -Path "C:\Program Files (x86)\PFPS\system\"

        Get-ChildItem -Path $dafifDirectory | Foreach-Object { 
                                                                DafifCommand.exe $_.FullName
                                                             }
        
        Write-Host -ForegroundColor Green -BackgroundColor Black "[*] DAFIF Updated Successfully [*]"

        $ts = TimeStamp ; Logger "[*] DAFIF updated at: $ts `n "
    }
    catch
    {
        Write-Host -ForegroundColor Red "[!] Failed to update DAFIF data [!]" 

        $ts = TimeStamp ; Logger "[!] Failed to update DAFIF data: $ts `n "

        return
    }

    Set-Location -Path $currentPath

}

function UpdateFLIP
{
    Write-Host -ForegroundColor Yellow "[*] Beginning FLIP update routine... "

    $currentPath = Get-Location

    $flipPath = Join-Path -Path $currentPath -ChildPath "\FLIP\"

    $targetPath = "C:\Users\Public\Documents\PFPS\FLIP\"

    $remPath = "C:\Users\Public\Documents\PFPS\FLIP\*"

    Write-Host -ForegroundColor Yellow "[*] Checking for the FLIP directory..." 

    $testTargetPath = Test-Path -Path $flipPath 

    if($testTargetPath)
    {
        $ts = TimeStamp ; Logger "[*] Located FLIP destination directory at: $ts `n "

        Write-Host -ForegroundColor Green "[*] FLIP Directory located "

        Write-Host -ForegroundColor Red -BackgroundColor Black "[*] Removing old FLIP Data " 

        Remove-Item -Recurse -Path $remPath -Force 

        $ts = TimeStamp ; Logger "[*] Removed old FLIP Data at: $ts `n "

        Write-Host -ForegroundColor Green "[*] Transferring new FLIP Data...this will take a while " 

        try
        {
                Get-ChildItem -Path $flipPath | Foreach-Object {
                                                       if((Get-Item $_.FullName) -is [System.IO.DirectoryInfo])
                                                       {
                                                        Write-Host -Foregroundcolor Green "[*] Copying: $_ -> $targetPath"; 
                                                        Copy-Item -Path $_.FullName -Recurse -Destination $targetPath ;
                                                       }
                                                       else
                                                       { 
                                                        Write-Host -Foregroundcolor Green "[*] Copying: $_ -> $targetPath"; 
                                                        Copy-Item -Path $_.FullName -Destination $targetPath ;
                                                       } 
                                                     }
        }
        catch
        {
            Write-Host -ForegroundColor Red "[!] Copy Operation Failed [!]" 

            $ts = TimeStamp ; Logger "[!] Error within FLIP import -- << Source: $_.FullName >> at: $ts `n "

            return
        }

        Write-Host -ForegroundColor Green -BackgroundColor Black "[*] Copy operation succeeded " 

        $ts = TimeStamp ; Logger "[*] FLIP Import Operation succeeded at: $ts `n "

        try
        {
            Write-Host -ForegroundColor Yellow "[*] Attempting FLIP coverage generation via Falcon View CLI Utility..." 

            & "C:\Program Files\PFPS\MapDataServer\FvCopy.exe" -c -d $flipPath * "C:\Users\Public\Documents\PFPS\FLIP\"

            Write-Host -ForegroundColor Green "[*] FLIP Data successfully populated via FV Utility " 

            $ts = TimeStamp ; Logger "[*] FLIP coverage integrated with FV data path at: $ts `n "

            Set-Location -Path $currentPath
        }
        catch
        {
            Write-Host -ForegroundColor Red "[!] Failed to update FLIP Data in FV -- Pursue a manual update via Data Administration Tool Set [!]"

            $ts = TimeStamp ; Logger "[!] FLIP coverage generation failed at: $ts `n "

            Set-Location -Path $currentPath
        }
    }
    else
    {
        Write-Host -ForegroundColor Red "[!] FLIP Update Routine Failed [!]" 

        $ts = TimeStamp ; Logger "[*] FLIP Update Routine failed at: $ts `n "

        return
    }
}

function UpdateECHUM
{
    Write-Host -ForegroundColor Yellow "[*] Beginning ECHUM update routine... "

    $currentLocation = Get-Location 

    $sourcePath = Join-Path -Path $currentLocation -ChildPath "\ECHUM\"

    $repository = "C:\Users\Public\Documents\PFPS\ECHUM\"

    $copyTarget = "C:\Users\Public\Documents\PFPS\ECHUM\"

    $checkRepo = Test-Path -Path $repository

    if($checkRepo)
    {
        Write-Host -ForegroundColor Green "[*] Located ECHUM Precursor Repository " 

        $ts = TimeStamp ; Logger "[*] ECHUM data located at: $ts `n "

        Write-Host -ForegroundColor Red -BackgroundColor Black "[X] Removing old data [X]" 

        Remove-Item -Path $repository -Recurse -Force

        Write-Host -ForegroundColor Yellow "[*] Embedding new ECHUM Precursor Data ..." 

        try
        {
            Copy-Item -Recurse -Path $sourcePath -Destination $copyTarget -Force 
          
            Write-Host -ForegroundColor Green "[*] New ECHUM Precursor Data Embedded Successfully " 

            $ts = TimeStamp ; Logger "[*] ECHUM data was embedded at: $ts `n "
        }
        catch
        {
            Write-Host -ForegroundColor Red "[!] Copy operation failed, departing... [!]"
            
            $ts = TimeStamp ; Logger "[!] ECHUM copy operation failed at: $ts `n " 
        }
        try
        {
            Write-Host -ForegroundColor Yellow "[*] Attempting ECHUM coverage generation via Falcon View CLI Utility..." 

            & "C:\Program Files\PFPS\MapDataServer\FvCopy.exe" -c -d $sourcePath * "C:\Users\Public\Documents\PFPS\ECHUM\"

            Write-Host -ForegroundColor Green "[*] ECHUM Data successfully populated via FV Utility " 

            $ts = TimeStamp ; Logger "[*] ECHUM Data successfully populated via FV Utility at: $ts `n "

            Set-Location -Path $currentLocation
        }
        catch
        {
            Write-Host -ForegroundColor Red "[!] Failed to update the ECHUM data path in FalconView -- Update manually via Map Data Manager [!]"

            $ts = TimeStamp ; Logger "[!] Failed to update the ECHUM data path in FalconView at: $ts `n "

            Set-Location -Path $currentLocation
        }
    }
    else
    {
        Write-Host -ForegroundColor Red "[!] Failed to modify ECHUM precursor directory and data [!]"  

        $ts = TimeStamp ; Logger "[!] Comprehensive failure of ECHUM update routine at: $ts `n "
    }

}

function UpdateCSD
{
    Write-Host -ForegroundColor Yellow "[*] Beginning CADRG Update Routine ... "

    Write-Host -ForegroundColor Yellow "[*] Checking for the presence of the FalconView CLI Utility..." 
    
    $pathTest = Test-Path -Path "C:\Program Files\PFPS\MapDataServer\FvCommand.exe"

    $currentLocation = Get-Location 

    $sourcePath = Join-Path -Path $currentLocation -ChildPath "\CSD\"
    
    if($pathTest)
    {
        Write-Host -ForegroundColor Green "[*] Located FV CLI Utility "

        $ts = TimeStamp ; Logger "[*] Located FV CLI Utility at: $ts `n "
    }
    else
    {
        Write-Host -ForegroundColor Red "[!] Failed to locate FV CLI Utility [!]" 
        
        $ts = TimeStamp ; Logger "[!] Failed to locate FV CLI Utility at: $ts `n "

        return
    }

    Write-Host -ForegroundColor Yellow "[*] Checking for the presence of new CADRG data... " 

    $dataTest = Test-Path -Path $sourcePath

    if($dataTest)
    {
        Write-Host -ForegroundColor Green "[*] Located CADRG data "

        $ts = TimeStamp ; Logger "[*] Located CADRG data at: $ts `n "
    }
    else
    {
        Write-Host -ForegroundColor Red "[!] Failed to locate CADRG data [!]"

        $ts = TimeStamp ; Logger "[!] Failed to locate CADRG data at: $ts `n "

        return
    }

    Write-Host -ForegroundColor Yellow "[*] Attempting CADRG data import operation ..." 

    try
    {
        Get-ChildItem -Path $sourcePath | Foreach-Object {
            
                                                                                        Write-Host -ForegroundColor Yellow "[*] Importing $_ "
         
                                                                                        & "C:\Program Files\PFPS\MapDataServer\FvCommand.exe" LoadCSDIndex $_.FullName
                    
                                                                                      } 
        
        Write-Host -ForegroundColor Green -BackgroundColor Black "[*] CADRG Imported Successfully " 

        $ts = TimeStamp ; Logger "[*] CADRG Imported Successfully at: $ts `n "
    }
    catch
    {
        Write-Host -ForegroundColor Red "[!] Failed to import CADRG data [!]"
        
        $ts = TimeStamp ; Logger "[!] Failed to import CADRG data at: $ts `n "

        return
    }
    try
    {
        Write-Host -ForegroundColor Yellow "[*] Attempting coverage generation via Falcon View CLI Utility..." 

        & "C:\Program Files\PFPS\MapDataServer\FvCopy.exe" -c -d $sourcePath * "C:\Users\Public\Documents\PFPS\CSD\"

        Write-Host -ForegroundColor Green "[*] CADRG Data successfully updated via FV Utility " 

        $ts = TimeStamp ; Logger "[*] CADRG Data successfully updated via FV Utility at: $ts `n "

        Set-Location -Path $currentLocation
     }
     catch
     {
        Write-Host -ForegroundColor Red "[!] Failed to update the CADRG data path in FalconView -- Update manually via Map Data Manager [!]"

        $ts = TimeStamp ; Logger "[!] Failed to update the CADRG data path in FalconView at: $ts `n "

        Set-Location -Path $currentLocation
     }
}

function UpdateVVOD
{
    Write-Host -ForegroundColor Yellow "[*] Beginning VVOD update routine... "
    
    $currentLocation = Get-Location 

    $sourcePath = Join-Path -Path $currentLocation -ChildPath "\VVOD\" 

    $repository = "C:\Users\Public\Documents\PFPS\VVOD\"

    $copyTarget = "C:\Users\Public\Documents\PFPS\VVOD\"

    $checkRepo = Test-Path -Path $repository

    if($checkRepo)
    {
        Write-Host -ForegroundColor Green "[*] Located VVOD Repository "
        
        $ts = TimeStamp ; Logger "[*] Located VVOD Repository at: $ts `n " 
    
        Write-Host -ForegroundColor Red -BackgroundColor Black "[X] Removing old data [X]"

        Remove-Item -Path $repository -Recurse -Force

        $ts = TimeStamp ; Logger "[*] Removed old VVOD data at: $ts `n "

        Write-Host -ForegroundColor Yellow "[*] Embedding new VVOD Data " 

        try
        {
            Get-ChildItem -Path $sourcePath | Foreach-Object {
                                                                if((Get-Item $_.FullName) -is [System.IO.DirectoryInfo])
                                                                {
                                                                    Write-Host -Foregroundcolor Green "[*] Copying: $_ -> $copyTarget"; 
                                                                    Copy-Item -Path $_.FullName -Verbose -Recurse -Destination $copyTarget ; 
                                                                }
                                                                else
                                                                { 
                                                                    Write-Host -Foregroundcolor Green "[*] Copying: $_ -> $copyTarget"; 
                                                                    Copy-Item -Path $_.FullName -Verbose -Destination $copyTarget ; 
                                                                } 
                                                              } 
          
            Write-Host -ForegroundColor Green -BackgroundColor Black "[*] New VVOD Data Embedded Successfully " 

            $ts = TimeStamp ; Logger "[*] New VVOD Data imported at: $ts `n "
         }
         catch
         {
            Write-Host -ForegroundColor Red "[!] VVOD Copy operation failed, departing... [!]" 

            $ts = TimeStamp ; Logger "[!] VVOD Copy operation failed at: $ts `n "
         }
         try
         {
            Write-Host -ForegroundColor Yellow "[*] Attempting coverage generation via Falcon View CLI Utility..." 

            & "C:\Program Files\PFPS\MapDataServer\FvCopy.exe" -c -d $sourcePath * "C:\Users\Public\Documents\PFPS\VVOD\"

            Write-Host -ForegroundColor Green "[*] VVOD Data successfully updated via FV Utility "
            
            $ts = TimeStamp ; Logger "[*] VVOD Data successfully updated via FV Utility at: $ts `n " 
         }
         catch
         {
            Write-Host -ForegroundColor Red "[!] Failed to update the VVOD data path in FalconView -- Update via Map Data Manager [!]"

            $ts = TimeStamp ; Logger "[!] Failed to update the VVOD data path in FalconView at: $ts `n "
         }
         Set-Location -Path $currentLocation

      }
      else
      {
         Write-Host -ForegroundColor Red "[!] Failed to modify VVOD directories and data [!]" 

         $ts = TimeStamp ; Logger "[!] Comprehensive failure in VVOD update routine at: $ts `n "
         
         Set-Location -Path $currentLocation 
      }
}

function UpdateTLM
{
    Set-Location -Path $currentLocation

    Write-Host -ForegroundColor Yellow "[*] Beginning TLM Update Routine ... "

    Write-Host -ForegroundColor Yellow "[*] Checking for the presence of the FalconView CLI Utility..." 

    $currentLocation = Get-Location 

    $sourcePath = Join-Path -Path $currentLocation -ChildPath "\TLM\"
    
    $pathTest = Test-Path -Path "C:\Program Files\PFPS\MapDataServer\FvCommand.exe"
    
    if($pathTest)
    {
        Write-Host -ForegroundColor Green "[*] Located FV CLI Utility "

        $ts = TimeStamp ; Logger "[*] Located FV CLI Utility at: $ts `n "
    }
    else
    {
        Write-Host -ForegroundColor Red "[!] Failed to locate FV CLI Utility [!]" 
        
        $ts = TimeStamp ; Logger "[!] Failed to locate FV CLI Utility at: $ts `n "

        return
    }

    Write-Host -ForegroundColor Yellow "[*] Checking for the presence of new TLM data... " 

    $dataTest = Test-Path -Path $sourcePath

    if($dataTest)
    {
        Write-Host -ForegroundColor Green "[*] Located TLM data "

        $ts = TimeStamp ; Logger "[*] Located TLM data at: $ts `n "
    }
    else
    {
        Write-Host -ForegroundColor Red "[!] Failed to locate TLM data [!]" 
        
        $ts = TimeStamp ; Logger "[!] Failed to locate TLM data at: $ts `n "

        return
    }

    Write-Host -ForegroundColor Yellow "[*] Attempting TLM data import operation ..." 

    try
    {
        Get-ChildItem -Path $sourcePath | Foreach-Object { 
                                                           try
                                                           {
                                                                & "C:\Program Files\PFPS\MapDataServer\FvCommand.exe" LoadTlmIndex $_.FullName
                                                           }
                                                           catch
                                                           {
                                                                Write-Host -ForegroundColor Red "[!] Invalid Directory [!]"
                                                           } 
                                                         }
        
        Write-Host -ForegroundColor Green -BackgroundColor Black "[*] TLM Imported Successfully "  
        
        $ts = TimeStamp ; Logger "[*] TLM Imported Successfully at: $ts `n " 
    }
    catch
    {
        Write-Host -ForegroundColor Red "[!] Failed to import TLM data [!]" 
        
        $ts = TimeStamp ; Logger "[!] Failed to import TLM data at: $ts `n "

        return
    }
    Set-Location -Path $currentLocation
}

function UpdateDZLZ
{
    Write-Host -ForegroundColor Yellow "[*] Beginning DZ\LZ Update Sequence ..." 

    $currentLocation = Get-Location 

    $sourcePath = Join-Path -Path $currentLocation -ChildPath "\DZLZ\"

    $dstPath = "C:\Users\Public\Documents\PFPS\DZLZ\"

    $testResponse = Test-Path -Path $sourcePath ; $dstTest = Test-Path -Path $dstPath

    if($testResponse -and $dstPath)
    {
        Write-Host -ForegroundColor Green "[*] Located source and destination folders "

        $ts = TimeStamp ; Logger "[*] Located source and destination folders at: $ts `n "

        Write-Host -ForegroundColor Green "[*] Importing DZ\LZ data ... "

        try
        {        
            Get-ChildItem -Path $sourcePath | Foreach-Object {
                                                                if((Get-Item $_.FullName) -is [System.IO.DirectoryInfo])
                                                                {
                                                                    Write-Host -Foregroundcolor Green "[*] Copying: $_ -> $dstPath"; 
                                                                    Copy-Item -Path $_.FullName -Recurse -Destination $dstPath ; 
                                                                }
                                                                else
                                                                { 
                                                                    Write-Host -Foregroundcolor Green "[*] Copying: $_ -> $dstPath"; 
                                                                    Copy-Item -Path $_.FullName -Destination $dstPath ; 
                                                                } 
                                                             } 
        }
        catch
        {
            Write-Host -Foreground Red "[!] ERROR: Failed to transfer DZ/LZ data [!]" 

            $ts = TimeStamp ; Logger "[!] ERROR: Failed to transfer DZ/LZ data at: $ts `n "
        }
        try
         {
            Write-Host -ForegroundColor Yellow "[*] Attempting coverage generation via Falcon View CLI Utility..." 

            & "C:\Program Files\PFPS\MapDataServer\FvCopy.exe" -c -d $sourcePath * "C:\Users\Public\Documents\PFPS\DZLZ\"

            Write-Host -ForegroundColor Green "[*] DZ\LZ Data successfully updated via FV Utility " 

            $ts = TimeStamp ; Logger "[*] DZ\LZ Data successfully updated via FV Utility at: $ts `n "
         }
         catch
         {
            Write-Host -ForegroundColor Red "[!] Failed to update the DZ\LZ data path in FalconView -- Update via Map Data Manager [!]"

            $ts = TimeStamp ; Logger "[!] Failed to update the DZ\LZ data path in FalconView at: $ts `n "
         }
         Set-Location -Path $currentLocation
    }
    else
    {
        Write-Host -ForegroundColor Red "[!] Failed to locate the DZ/LZ update data [!]"

        $ts = TimeStamp ; Logger "[!] Failed to locate the DZ/LZ update data at: $ts `n "
     
        Set-Location -Path $currentLocation
        
        return
    }
}

function ExportNAVDB
{
    $currentUser = $env:USERNAME

    Write-Host -ForegroundColor Yellow "[*] Navigation Database Export Sequence ..."

    $currentLocation = Get-Location 

    $sourcePath = Join-Path -Path $currentLocation -ChildPath "\NAVDB\DTU\"

    $dafifLocation = Join-Path -Path $currentLocation -ChildPath "\DAFIF\DAFIF\VERSION"

    $dafifData = Get-Content -Path $dafifLocation -Raw

    if($dafifData -match "\s\d\d\d\d")
    {
        $dafifVersion = $matches[0] ;  ; $dafifVersion = $dafifVersion.TrimStart()

        Write-Host -ForegroundColor Green "[*] DAFIF Version Identified: $dafifVersion "

        $ts = TimeStamp ; Logger "[*] DAFIF Version Identified as $dafifVersion at: $ts `n "

        $directoryName = $dafifVersion+' '+"CRD"

        $present = Test-Path -Path "C:\Users\$currentUser\Desktop\$directoryName"
        
        if($present)
        {
            Remove-Item -Force -Recurse -Path "C:\Users\$currentUser\Desktop\$directoryName"

            Write-Host -ForegroundColor Green "[*] Removed previous directory at: $ts "
        }

        New-Item -Type Directory -Path "C:\Users\$currentUser\Desktop\$directoryName" | Out-Null

        $ts = TimeStamp ; Logger "[*] Creating directory: $dafifVersion CRD at: $ts "

        Write-Host -ForegroundColor Yellow "[*] Exporting Navigation Database ..."

        Copy-Item -Path $sourcePath -Recurse -Destination "C:\Users\$currentUser\Desktop\$directoryName"

        Write-Host -ForegroundColor Green "[*] Navigation Database Export sequence is complete "

        $ts = TimeStamp ; Logger "[*] Navigation Database Export sequence is complete at: $ts "
    }
    else
    {
        Write-Host -ForegroundColor Red "[!] Failed to locate DAFIF Version Data -- Navigation Database not Exported [!]"

        $ts = TimeStamp ; Logger "[!] Failed to locate DAFIF Version Data at: $ts "

        return
    }
}

function UpdateAV
{
    Write-Host -ForegroundColor Yellow "[*] Beginning antivirus update routine... "

    $currentLocation = Get-Location 

    $sourcePath = Join-Path -Path $currentLocation -ChildPath "\AV\*\*"

    try
    {
        Write-Host -ForegroundColor Yellow -BackgroundColor DarkGray "[*] Stopping McAfee Services..."
        Stop-Service -Name masvc -Force
        Stop-Service -Name McAfeeFramework -Force
        Stop-Service -Name McShield -Force
        Stop-Service -Name McTaskManager -Force 
        Stop-Service -Name mfefire -Force
        Stop-Service -Name mfemms -Force
        Stop-Service -Name mfevtp -Force 

        $ts = TimeStamp ; Logger "[*] Stopped AntiVirus Related Services at: $ts "
    }
    catch
    {
        Write-Host -ForegroundColor Red "[!] Failed to stop an AV supporting service [!]"

        $ts = TimeStamp ; Logger "[!] Failed to stop AV service at: $ts "
    }

    Write-Host -ForegroundColor Yellow "[*] Updating Anti-Virus Signatures... " 

    $ts = TimeStamp ; Logger "[*] Updating AV signatures at: $ts "

    $targetPath = "C:\Program Files (x86)\Common Files\McAfee\Engine\"

    $testTargetPath = Test-Path -Path $targetPath

    if($testTargetPath)
    {
        Write-Host -ForegroundColor Green "[*] Located McAfee Engine Directory " 

        $ts = TimeStamp ; Logger "[*] Located AV directory on host at: $ts "
    }

    Write-Host -ForegroundColor Yellow -BackgroundColor Grey "[*] Removing existing signature files..." 

    Get-ChildItem -Path $targetPath | Foreach-Object {
                                                       $fileObject = $_
                                                       
                                                       if([string]$fileObject -eq 'avvclean.dat' -or [string]$fileObject -eq 'avvnames.dat' -or [string]$fileObject -eq 'avvscan.dat')
                                                       {
                                                            Write-Host -ForegroundColor Red -BackgroundColor Black "[X] Removing: $_ [X]" 

                                                            Remove-Item -Path $_.FullName -Force 
                                                       }    
                                                     }

    $ts = TimeStamp ; Logger "[*] Removed existing signature files at: $ts "

    Write-Host -ForegroundColor Yellow "[*] Embedding new signature files..." 

    Get-ChildItem -Path $sourcePath | Foreach-Object {
                                                                                    
                                                                                    Write-Host -ForegroundColor Yellow -BackgroundColor DarkGray "[*] Embedding: $_ " 

                                                                                    Copy-Item -Path $_.FullName -Recurse -Destination $targetPath -Force
                                                       
                                                     }

    Write-Host -ForegroundColor Green -BackgroundColor Black "[*] Anti-Virus Signatures Updated Successsfully [*]"

    $ts = TimeStamp ; Logger "[*] AV Signatures Successfully Updated at: $ts "

    try
    {
        Write-Host -ForegroundColor Green -BackgroundColor DarkGray "[*] Starting McAfee Services..." 
        Start-Service -Name masvc -Force
        Start-Service -Name McAfeeFramework -Force
        Start-Service -Name McShield -Force
        Start-Service -Name McTaskManager -Force 
        Start-Service -Name mfefire -Force
        Start-Service -Name mfemms -Force
        Start-Service -Name mfevtp -Force 

        $ts = TimeStamp ; Logger "[*] Started AV Services at: $ts "
    }
    catch
    {
        Write-Host -ForegroundColor Red "[!] Failed to bring an AV supporting service back to running status [!]"

        $ts = TimeStamp ; Logger "[*] Failed to restart AV service at: $ts "
    }
}

function ApplyPatches
{
    Write-Host -ForegroundColor Yellow "[*] Beginning patch application sequence..." 

    Write-Host -ForegroundColor Yellow "[*] Determining release ID..."

    $build = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\" -Name ReleaseID | Select-Object ReleaseID
    
    $buildID = $build.ReleaseId

    Write-Host -ForegroundColor Green "[*] Release ID: $buildID "

    $ts = TimeStamp ; Logger "[*] Determined release ID at: $ts "

    Write-Host -ForegroundColor Yellow "[*] Searching for applicable updates... "

    $currentLocation = Get-Location 

    $sourcePath = Join-Path -Path $currentLocation -ChildPath "\PATCHES\Baseline\"

    Get-ChildItem -Path $sourcePath | Foreach-Object { $directory = $_.Name  ; if($directory -eq $buildID) {

                                                                                    $ts = TimeStamp ; Logger "[*] Located applicable update directory at: $ts "

                                                                                    Write-Host -ForegroundColor Green "[*] Located a corresponding directory: $directory "

                                                                                    $directory = $sourcePath+$directory+"\"

                                                                                    Get-ChildItem -Path $directory | Foreach-Object {

                                                                                    $update = $_ ; $segments = $update -Split "-"
                                                                                    
                                                                                    $segments | Foreach-Object {

                                                                                                                $segment = $_

                                                                                                                if($segment.Substring(0,2) -eq 'kb')
                                                                                                                {
                                                                                                                    $update = $segment

                                                                                                                    Write-Host -ForegroundColor Yellow "[*] Checking: $update ..."

                                                                                                                    $isInstalled = Get-Hotfix -Id $update

                                                                                                                    if($isInstalled)
                                                                                                                    {
                                                                                                                        Write-Host -ForegroundColor Green "[*] Update is already in place [*]" 
                                                                                                                    }
                                                                                                                    else
                                                                                                                    {
                                                                                                                        Write-Host -ForegroundColor Yellow "[!] Update has not been applied yet [!]"

                                                                                                                        Write-Host -ForegroundColor Yellow "[*] Applying update... " 

                                                                                                                        $ts = TimeStamp ; Logger "[*] Applying update-> $update at: $ts "

                                                                                                                        wusa $update /quiet

                                                                                                                        Write-Host -ForegroundColor Green -BackgroundColor Black "[*] Successfully Applied: $update [*]"

                                                                                                                        $ts = TimeStamp ; Logger "[*] Update-> $update applied at: $ts "
                                                                                                                    }
                                                                                                                 }
                                                                                                                 else
                                                                                                                 {
                                                                                                                    Write-Host -ForegroundColor DarkMagenta "[*] Searching..." 
                                                                                                                 }
                                                                                                                } 
                                                                                                               }
                                                                                }
                                                       else
                                                       {
                                                            Write-Host -ForegroundColor Yellow "[*] Directory is not applicable "
                                                       }
                                                      }
    Write-Host -ForegroundColor Green "[*] Patch application routine complete "

    $ts = TimeStamp ; Logger "[*] Updates application sequence completed at: $ts "
}

function DirectoryStructure
{
    Write-Host -ForegroundColor Yellow "[*] Checking directory structure... "

    $directories = @()

    $flipDir  = "C:\Users\Public\Documents\PFPS\FLIP" ; $directories += $flipDir
    $echumDir = "C:\Users\Public\Documents\PFPS\ECHUM"; $directories += $echumDir
    $csdDir   = "C:\Users\Public\Documents\PFPS\CSD"  ; $directories += $csdDir
    $vvodDIr  = "C:\Users\Public\Documents\PFPS\VVOD" ; $directories += $vvodDir
    $dzlzDir  = "C:\Users\Public\Documents\PFPS\DZLZ" ; $directories += $dzlzDir
    
    $directories | Foreach-Object {
                                    $check = Test-Path -Path $_
                                    if($check)
                                    {
                                        Write-Host -ForegroundColor Green "[*] Directory in place at: $_ "
                                    }
                                    else
                                    {
                                        New-Item -Type Directory -Path $_ -Force | Out-Null

                                        Write-Host -ForegroundColor Green "[*] Created: $_ "
                                    } 
                                  } 

   Write-Host -ForegroundColor Green "[*] Target directory structure adequate " 

   $ts = TimeStamp ; Logger "[*] Directory structure determined to be adequate at: $ts "
}

function EmbedCutter
{
    $currentUser = $env:USERNAME

    try
    {
        $res = Test-Path -Path "C:\Users\$currentUser\Desktop\cutter.exe"

        if($res)
        {
            Write-Host -ForegroundColor Green "[*] PCMCIA Cutter is in place "

            $ts = TimeStamp ; Logger "[*] Card Cutter was determined to be in place at: $ts "
        }
        else
        {
            $ccDir = Join-Path -Path $currentLocation -ChildPath "\CC\cutter.exe"

            Copy-Item -Path $ccDir -Destination "C:\Users\$currentUser\Desktop\cutter.exe"

            $ts = TimeStamp ; Logger "[*] Card Cutter copied to the desktop at: $ts "
        }
    }
    catch
    {
        return
    }
}

function GenerateLogfile
{
    $currentUser = $env:USERNAME

    $updateDirectory = Get-Location

    $year     = (Get-Date).Year
    $month    = (Get-Date).Month
    $day      = (Get-Date).Day
    $hours    = (Get-Date).TimeOfDay.Hours
    $minutes  = (Get-Date).TimeOfDay.Minutes
    $seconds  = (Get-Date).TimeOfDay.Seconds
    $tod      = "_"+[string]$year+'_'+[string]$month+'_'+[string]$day+"_"+[string]$hours+'_'+[string]$minutes+'_'+[string]$seconds+".log"
    $ts       = [string]$year+'-'+[string]$month+'-'+[string]$day+"-"+[string]$hours+':'+[string]$minutes+':'+[string]$seconds
    $fileName = "update_log"+$tod
    $logPath  = "C:\Users\$currentUser\Desktop\$fileName"
    $logFile = New-Item -Type File -Path $logPath | Out-Null

    Write-Host -ForegroundColor Magenta "[*] Log file created at: $logPath ... " ; Start-Sleep -Seconds 1

    return $logPath
}

function TimeStamp
{
    $year     = (Get-Date).Year
    $month    = (Get-Date).Month
    $day      = (Get-Date).Day
    $hours    = (Get-Date).TimeOfDay.Hours
    $minutes  = (Get-Date).TimeOfDay.Minutes
    $seconds  = (Get-Date).TimeOfDay.Seconds
    $ts       = [string]$year+'-'+[string]$month+'-'+[string]$day+"-"+[string]$hours+':'+[string]$minutes+':'+[string]$seconds

    return $ts
}

function Logger
{
    Param([string]$logstring)

    Add-Content $logfile -value $logstring
}

function main
{
    $timer = [System.Diagnostics.Stopwatch]::StartNew()

    <###>

    Write-Host -ForegroundColor Green "[*] Beginning monthly update script..."

    <###>

    $ts = TimeStamp ; Logger "[*] Initiated update script at: $ts `n "

    Write-Host -BackgroundColor DarkGray -ForegroundColor Green "[*] Checking the update target directories [*]"

    $ts = TimeStamp ; Logger "[*] Checked directory structure at: $ts `n "

    DirectoryStructure

    Write-Host -BackgroundColor DarkGray -ForegroundColor Green "[*] Embedding the PCMCIA Cutter [*]"

    $ts = TimeStamp ; Logger "[*] Embedded the PCMCIA card cutter application on the desktop at: $ts `n "

    EmbedCutter

    Write-Host -BackgroundColor DarkGray -ForegroundColor Green "[*] Beginning the DAFIF Update Sequence [*]"
    
    $ts = TimeStamp ; Logger "[*] Initiated DAFIF update sequence at: $ts `n " 

    UpdateDAFIF

    Write-Host -BackgroundColor DarkGray -ForegroundColor Green "[*] Beginning the FLIP Transfer Sequence [*]"
    
    $ts = TimeStamp ; Logger "[*] Initiated FLIP update sequence at: $ts `n " 

    UpdateFLIP

    Write-Host -BackgroundColor DarkGray -ForegroundColor Green "[*] Beginning the ECHUM Transfer Sequence [*]" 

    $ts = TimeStamp ; Logger "[*] Initiated ECHUM update sequence at: $ts `n "

    UpdateECHUM

    Write-Host -BackgroundColor DarkGray -ForegroundColor Green "[*] Beginning the CSD Update Sequence [*]" 

    $ts = TimeStamp ; Logger "[*] Initiated CADRG update sequence at: $ts `n "

    UpdateCSD

    Write-Host -BackgroundColor DarkGray -ForegroundColor Green "[*] Beginning the VVOD Transfer Sequence [*]"

    $ts = TimeStamp ; Logger "[*] Initiated VVOD update sequence at: $ts `n "

    UpdateVVOD

    Write-Host -BackgroundColor DarkGray -ForegroundColor Green "[*] Beginning the TLM Update Sequence [*]" 

    $ts = TimeStamp ; Logger "[*] Initiated the TLM update sequence at: $ts `n "

    UpdateTLM

    Write-Host -BackgroundColor DarkGray -ForegroundColor Green "[*] Beginning the DZ\LZ Update Sequence [*]" 

    $ts = TimeStamp ; Logger "[*] Initiated DZ/LZ update sequence at: $ts `n "

    UpdateDZLZ

    Write-Host -BackgroundColor DarkGray -ForegroundColor Green "[*] Updating Anti-Virus Signatures [*]" 

    $ts = TimeStamp ; Logger "[*] Initiated Antivirus Signature update sequence at: $ts `n "

    UpdateAV

    Write-Host -BackgroundColor DarkGray -ForegroundColor Green "[*] Applying OS and Application Patches [*]"
    
    $ts = TimeStamp ; Logger "[*] Initiated Patching sequence at: $ts `n " 

    ApplyPatches

    Write-Host -BackgroundColor DarkGray -ForegroundColor Green "[*] Exporting navigation database data to the desktop [*]"
    
    $ts = TimeStamp ; Logger "[*] Exported Navigation Database at: $ts `n " 

    ExportNAVDB

    Write-Host "`n"

    Write-Host -BackgroundColor Black -ForegroundColor Green "[*][*][*] Update Complete [*][*][*]"

    $ts = TimeStamp ; Logger "[*] Update completed at: $ts `n "

    Clear-Host

    $hours   = $timer.Elapsed.Hours
    $minutes = $timer.Elapsed.Minutes
    $seconds = $timer.Elapsed.Seconds

    $ts = TimeStamp ; Logger "[*] Net execution time: $hours : $minutes :$seconds `n "

    Write-Host -ForegroundColor Magenta "[*] Net Execution Time (h\m\s): $hours : $minutes : $seconds " ; Start-Sleep -Seconds 3 ; Clear-Host

    Restart-Computer -Force 
}

$currentLocation = Get-Location

$ErrorActionPreference = "SilentlyContinue"

$logfile = GenerateLogfile

main

