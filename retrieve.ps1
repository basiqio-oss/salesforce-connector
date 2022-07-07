# Run once manually: Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
New-Item -ItemType directory -Path download
sfdx force:mdapi:retrieve -s -r download -u mario@basiq.io -p "Basiq Connector"
Set-Location download
# Change extractor path if needed.
C:\Progra~1\7-Zip\7z.exe x unpackaged.zip -aoa
Copy-Item package.xml ..\
Set-Location ..
sfdx force:mdapi:convert --rootdir download
Remove-Item -LiteralPath download -Force -Recurse
# This line will overwrite any changes made in originals of *.dup files. Be careful!
Get-ChildItem -Recurse -Include *.dup | Move-Item -Path { $_ } -Destination { $_.FullName.replace(".dup", "") } -Force
