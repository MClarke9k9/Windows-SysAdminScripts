 # This Powershell script will be able to run and shorten various task needed.

$scriptDir =  Split-Path -Parent $MyInvocation.MyCommand.Split-Path
if ($PSCommandPath) {
    $scriptDir = Split-Path -Parent $PSCommandPath
} else {
    $scriptDir = (Get-Location).Path
}

try {
    do {
        Clear-Host

        Write-Host "=================================="
        Write-Host "      System Checks Menu          "
        Write-Host "=================================="
        Write-Host "1. Append .log file listing to DailyLog.txt (with date header)"
        Write-Host "2. Save System Check contents to C916contents.txt (tabular, A-Z)"
        Write-Host "3. Display current CPU and memory usage"
        Write-Host "4. Display running processes sorted by virtual memory (grid view)"
        Write-Host "5. Exit"
        Write-Host "=================================="
        $selection = Read-Host "Please enter your selection (1-5)"

        switch ($selection) {
           '1' {
                $logFilePath = Join-Path $scriptDir 'DailyLog.txt'

                $timestamp = Get-Date -Format 'yyy-MM-dd HH:mm:ss'
                "===== $timestamp =====" | Out-File -FilePath $logFilePath -Append

                Get-ChildItem -Path $scriptDir -File |
                    Where-Object { $_.Name -match '\.log$'} |
                    Select-Object Name, Length, LastWriteTime |
                    Out-File -FilePath $logFilePath -Append
                "" | Out-File -FilePath $logFilePath -Append
                
                Write-Host "`n[Option 1] Log files have been appended to the Dailylog.txt"
           }

           '2' {
                $contentsFilePatch = Join-Path $scriptDir 'C916contents.txt'

                Get-ChildItem -Path $scriptDir -File |
                    Sort-Object Name |
                    Format-Table Name, Length, LastWriteTime -AutoSize |
                    Out-File -FilePath $contentsFilePatch

                Write-Host "`n[Option 2] Folder contents have been saved to C916contents.txt"
           }
           '3' {
               
                Write-Host "`n[Option 3] Current CPU and memory usage:`n"

                $cpuSample = Get-Counter '\Processor(_Total)\% Processor Time'
                $cpuValue = [math]::Round($cpuSample.CounterSamples.CookedValue, 2)

                $osInfo      = Get-CimInstance -ClassName Win32_OperatingSystem
                $totalMemMB  = [math]::Round($osInfo.TotalVirtualMemorySize / 1KB, 2)
                $freeMemMB   = [math]::Round($osInfo.FreePhysicalMemory / 1KB, 2)
                $usedMemMB   = [math]::Round($totalMemMB - $freeMemMB, 2)

                Write-Host ("CPU Usage (%)        : {0}" -f $cpuValue)
                Write-Host ("Total Memory (MB)    : {0}" -f $totalMemMB)
                Write-Host ("Used Memory (MB)     : {0}" -f $usedMemMB)
                Write-Host ("Free Memory (MB)     : {0}" -f $freeMemMB)
           }
           '4' {

                Write-Host "`n[Option 4] Opening running processes in a grid view..."
                Write-Host "Close the grid window to return to the menu.`n"

                Get-Process |
                    Sort-Object VM |
                    Out-GridView -Title "Running processes sorted by Virtual Memory (VM)"
           }
           '5' {
                Write-Host "`n[Option 5] Exiting the script. bye bye! :)"
                break
           }
           Default {
                Write-Host "`nInvalid selection. Please choose a number from 1 to 5."
           }

        }
        if ($selection -ne '5') {
            Write-Host
            Read-Host "Press Enter to return to the menu"
        
        }
        
    } while ($selection -ne '5')

} catch [System.OutOfMemoryException] {
    Write-Host "A System.OutOfMemoryException occured: $($_.Exception.Message)"
    Write-Host "The script will now exit due to insufficent memory."
}