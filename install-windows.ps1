# Stockly for Windows - install, or update, with one line in PowerShell:
#
#   irm https://huzaifa1121.github.io/stockly-download/install-windows.ps1 | iex
#
# Why a line in PowerShell instead of a downloaded file: Windows warns about,
# or blocks, files a browser downloads ("Windows protected your PC") unless
# they are signed with a paid certificate. Files fetched by PowerShell itself
# are not marked as downloaded, so nothing here is blocked. "irm | iex" runs
# this text inside the PowerShell window that is already open, so the
# execution policy (which only checks script FILES) does not stop it either.
#
# Installs into %USERPROFILE%\Stockly, adds Stockly to the Start Menu, and
# runs the usual setup. Run it again to update: the shop's data, settings,
# licence and logs are kept.
#
# For testing, STOCKLY_ZIP_URL can point at another zip (a web address or a
# file on this computer):   $env:STOCKLY_ZIP_URL = 'C:\path\stockly.zip'
#
# Written for Windows PowerShell 5.1 (what every Windows 10/11 has), in plain
# ASCII. Everything is inside a function, so a failure never closes the
# shopkeeper's PowerShell window.

function Install-Stockly {
  $ErrorActionPreference = 'Stop'
  # Without this, Windows PowerShell 5.1 downloads very slowly.
  $ProgressPreference = 'SilentlyContinue'

  $AppDir = Join-Path $env:USERPROFILE 'Stockly'
  $ZipUrl = 'https://github.com/Huzaifa1121/stockly-download/releases/latest/download/stockly.zip'
  if ($env:STOCKLY_ZIP_URL) { $ZipUrl = $env:STOCKLY_ZIP_URL }
  $StartMenuDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Stockly'
  $StartupLink = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\Stockly.lnk'
  $Cmd = Join-Path $env:SystemRoot 'System32\cmd.exe'
  $PowerShellExe = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'

  function Say([string]$text) { Write-Host ''; Write-Host "  $text" }
  function Fail([string]$text) { throw (New-Object System.Exception $text) }

  # The port Stockly answers on, or $null. It must say "app":"stockly", so
  # another program on the port is never mistaken for it (or stopped).
  function Get-StocklyPort {
    foreach ($p in 3000..3005) {
      try {
        $r = Invoke-WebRequest -Uri "http://127.0.0.1:$p/api/health" -UseBasicParsing -TimeoutSec 2
        if ($r.Content -match '"app"\s*:\s*"stockly"') { return $p }
      } catch { }
    }
    return $null
  }

  # Runs  cmd /c ""<file>" <args>"  - the outer quotes keep a folder with
  # spaces or brackets in its name in one piece.
  function Get-CmdLine([string]$file, [string]$arguments) {
    $line = '/d /s /c ""' + $file + '"'
    if ($arguments) { $line += ' ' + $arguments }
    return $line + '"'
  }

  function Stop-Stockly {
    # taskkill's own messages are not errors worth stopping for. (With 'Stop',
    # Windows PowerShell 5.1 treats any text a program writes to its error
    # output as a failure.)
    $ErrorActionPreference = 'Continue'
    $stopped = $false
    # 1. Whatever answers as Stockly: stop the program listening on that port.
    $port = Get-StocklyPort
    if ($port) {
      $pids = @()
      try {
        $pids = @(Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction Stop |
                  Select-Object -ExpandProperty OwningProcess -Unique)
      } catch {
        # Older Windows without Get-NetTCPConnection: read netstat instead.
        foreach ($line in (netstat -ano)) {
          $cols = -split $line
          if ($cols.Count -ge 5 -and $cols[1] -like "*:$port" -and $cols[3] -eq 'LISTENING') { $pids += [int]$cols[4] }
        }
      }
      foreach ($id in $pids) {
        if ($id -gt 0) { & taskkill.exe /pid $id /t /f 2>&1 | Out-Null; $stopped = $true }
      }
    }
    # 2. Any Node still running from inside the Stockly folder (helpers, or an
    #    older Stockly that does not name itself yet). Its files would be in
    #    use, and Windows does not let files in use be replaced.
    $inside = $AppDir.TrimEnd('\') + '\'
    try {
      $nodes = @(Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction Stop)
    } catch {
      $nodes = @(Get-WmiObject Win32_Process -Filter "Name='node.exe'")
    }
    foreach ($n in $nodes) {
      if ($n.CommandLine -and $n.CommandLine.IndexOf($inside, [StringComparison]::OrdinalIgnoreCase) -ge 0) {
        & taskkill.exe /pid $n.ProcessId /t /f 2>&1 | Out-Null
        $stopped = $true
      }
    }
    if ($stopped) { Start-Sleep -Seconds 2 }
  }

  if ($env:OS -ne 'Windows_NT') { Fail 'This installer is for Windows. On a Mac, use the Mac line from the website.' }

  # GitHub only speaks TLS 1.2 or newer; older Windows PowerShell may not
  # offer it unless asked.
  try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
  } catch { }

  Write-Host ''
  Write-Host '  Stockly - installing on this computer'
  Write-Host '  ====================================='

  $Tmp = Join-Path $env:TEMP ('stockly-install-' + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $Tmp -Force | Out-Null
  try {
    $Zip = Join-Path $Tmp 'stockly.zip'
    Say 'Downloading Stockly...'
    if ($ZipUrl -match '^https?://') {
      try {
        Invoke-WebRequest -Uri $ZipUrl -OutFile $Zip -UseBasicParsing
      } catch {
        Fail 'Could not download Stockly. Is this computer connected to the internet?'
      }
    } else {
      # A zip on this computer, for testing.
      if (-not (Test-Path -LiteralPath $ZipUrl)) { Fail "There is no file at $ZipUrl" }
      Copy-Item -LiteralPath $ZipUrl -Destination $Zip
    }

    $Unpacked = Join-Path $Tmp 'x'
    try {
      Expand-Archive -LiteralPath $Zip -DestinationPath $Unpacked -Force
    } catch {
      Fail 'The download looks damaged. Please try again.'
    }
    # The zip holds one folder (stockly-...), or the files directly.
    $Src = $Unpacked
    if (-not (Test-Path -LiteralPath (Join-Path $Src 'setup.bat'))) {
      $first = Get-ChildItem -LiteralPath $Unpacked -Directory |
               Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'setup.bat') } |
               Select-Object -First 1
      if ($first) { $Src = $first.FullName }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $Src 'setup.bat'))) { Fail 'The download looks damaged. Please try again.' }
    # In case the zip itself was marked as downloaded (a test zip from a
    # browser), clear the mark so Windows does not question each file.
    Get-ChildItem -LiteralPath $Src -Recurse -File | Unblock-File -ErrorAction SilentlyContinue

    # Replace the program, never the shop: these stay exactly as they are.
    $Keep = @('data', '.env', 'licence.key', 'node_modules', '.next', 'logs')

    if (Test-Path -LiteralPath $AppDir) {
      # Never empty a folder that only happens to be called Stockly.
      $isStockly = (Test-Path -LiteralPath (Join-Path $AppDir 'setup.bat')) -or
                   (Test-Path -LiteralPath (Join-Path $AppDir 'data\stockly.db'))
      $isEmpty = -not (Get-ChildItem -LiteralPath $AppDir -Force | Select-Object -First 1)
      if (-not $isStockly -and -not $isEmpty) {
        Fail "There is already a folder $AppDir that is not Stockly. Rename or move it, then run this line again."
      }
      Say "Updating Stockly in $AppDir - your shop's records are kept."
      # Stop the running copy so its files can be replaced.
      Stop-Stockly
      try {
        foreach ($item in @(Get-ChildItem -LiteralPath $AppDir -Force)) {
          if ($Keep -notcontains $item.Name) {
            Remove-Item -LiteralPath $item.FullName -Recurse -Force
          }
        }
      } catch {
        Fail "Some of Stockly's files are in use. Double-click Stop Stockly in $AppDir (or restart the computer), then run this line again. Your records are safe."
      }
    } else {
      Say "Installing Stockly in $AppDir"
      New-Item -ItemType Directory -Path $AppDir -Force | Out-Null
    }
    foreach ($item in @(Get-ChildItem -LiteralPath $Src -Force)) {
      $target = Join-Path $AppDir $item.Name
      # A licence already on this computer wins over one in the download.
      if (($Keep -contains $item.Name) -and (Test-Path -LiteralPath $target)) { continue }
      Copy-Item -LiteralPath $item.FullName -Destination $AppDir -Recurse -Force
    }
  } finally {
    Remove-Item -LiteralPath $Tmp -Recurse -Force -ErrorAction SilentlyContinue
  }

  # ------------------------------------------------------------ Start Menu
  # "Stockly" in the Start Menu, with Stockly's icon. It opens Stockly,
  # starting it quietly first if it is not running. It sits in its own
  # Stockly folder so it is never confused with a Stockly app installed from
  # Chrome or Edge (start.bat looks for those).
  Say 'Adding Stockly to the Start Menu...'
  try {
    New-Item -ItemType Directory -Path $StartMenuDir -Force | Out-Null
    $shell = New-Object -ComObject WScript.Shell
    $link = $shell.CreateShortcut((Join-Path $StartMenuDir 'Stockly.lnk'))
    $link.TargetPath = $PowerShellExe
    $link.Arguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + (Join-Path $AppDir 'scripts\start-hidden.ps1') + '" -Open'
    $link.WorkingDirectory = $AppDir
    $link.WindowStyle = 7
    $link.Description = 'Open Stockly'
    $icon = Join-Path $AppDir 'src\app\favicon.ico'
    if (Test-Path -LiteralPath $icon) { $link.IconLocation = $icon + ',0' }
    $link.Save()
  } catch {
    Write-Host '  Could not add it to the Start Menu. Use Start Stockly in the Stockly folder instead.'
  }

  # ------------------------------------------------------------ setup
  # Installs Node if needed, prepares the data file, builds, and offers to
  # start Stockly by itself whenever the computer turns on. It asks its
  # questions in this window.
  Write-Host ''
  $setup = Start-Process -FilePath $Cmd -ArgumentList (Get-CmdLine (Join-Path $AppDir 'setup.bat') '--from-launcher') `
    -WorkingDirectory $AppDir -NoNewWindow -PassThru
  $null = $setup.Handle   # so the exit code can be read afterwards
  $setup.WaitForExit()
  if ($setup.ExitCode -ne 0) {
    Fail 'Setup did not finish (see above). Run this line again once that is sorted out - nothing will be lost.'
  }

  # Setup may have just installed Node; this window does not know where yet.
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')

  Say 'Stockly is installed.'
  Write-Host '  Open it any time from the Start Menu: look for Stockly.'
  Write-Host ''

  # ------------------------------------------------------------ open it now
  if (Test-Path -LiteralPath $StartupLink) {
    # Set to start by itself: start it quietly now, then show it.
    Write-Host '  Starting Stockly...'
    $hidden = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + (Join-Path $AppDir 'scripts\start-hidden.ps1') + '" -Open'
    Start-Process -FilePath $PowerShellExe -ArgumentList $hidden -WorkingDirectory $AppDir -WindowStyle Hidden
    Write-Host '  It opens in your browser in a moment.'
    Write-Host ''
  } else {
    # Not set to start by itself: run it in its own window, as Start Stockly
    # does. Closing that window stops Stockly.
    Start-Process -FilePath $Cmd -ArgumentList (Get-CmdLine (Join-Path $AppDir 'Start Stockly.bat') '') -WorkingDirectory $AppDir
    Write-Host '  Stockly is starting in a new window. Keep that window open while you use it.'
    Write-Host ''
  }
}

try {
  Install-Stockly
} catch {
  Write-Host ''
  Write-Host ('  ' + $_.Exception.Message)
  Write-Host '  If this keeps happening, send a photo of this window to whoever sold you Stockly.'
  Write-Host ''
}
