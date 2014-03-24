@echo off
powershell.exe -ExecutionPolicy RemoteSigned -Command "[Console]::SetBufferSize(1000, 3000)"
powershell.exe -ExecutionPolicy RemoteSigned -File "InstallLocal.ps1"
pause