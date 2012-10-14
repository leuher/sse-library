Function TempPath ($item) {
    return Join-Path (Get-Item Env:\TEMP).Value -ChildPath $item
}

Function PythonPath {
    (Get-ItemProperty HKLM:\SOFTWARE\Python\PythonCore\2.7\InstallPath)."(default)"
}

Function Download ($url, $file) {
    $dl = TempPath($file)
    
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($url, $dl)
    
    return $dl
}

Function GetArchitecture {
    if ([IntPtr]::Size -Eq 4) {
        return 32
    }
    
    return 64
}

function Test-Command([string] $CommandName)
{
    (Get-Command $CommandName -ErrorAction SilentlyContinue) -ne $null
}

Write-Host "Checking for Python 2.7"
if (Test-Path HKLM:\SOFTWARE\Python\PythonCore\2.7) {
    Write-Host "Python 2.7 Found"
} else {
    Write-Host "Python 2.7 Not Found"
    Write-Host "Downloading Python 2.7"
    
    if (GetArchitecture -Eq 32) {
        $pyinstall =
            Download "http://www.python.org/ftp/python/2.7.3/python-2.7.3.msi" "python-2.7.3.msi"
    } else {
        $pyinstall =
            Download "http://www.python.org/ftp/python/2.7.3/python-2.7.3.amd64.msi" "python-2.7.3.msi"
    }
    
    Invoke-Expression $pyinstall
}

Write-Host "Checking for Easy Install" # Easy my ASS
if (Test-Command easy_install.exec) {
    Write-Host "Easy Install Found (Isn't that easy?)"
} else {
    Write-Host "Installing Easy Install"
    
    $easy_install_script = Download "http://peak.telecommunity.com/dist/ez_setup.py" "easy_install_script.py"
    Invoke-Expression $easy_install_script
}

Write-Host "Checking for pip"