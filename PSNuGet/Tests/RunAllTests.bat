@echo off
powershell.exe -ExecutionPolicy RemoteSigned -Command "[Console]::SetBufferSize(1000, 3000)"
powershell.exe -ExecutionPolicy RemoteSigned -Command "Invoke-Tests -Recurse"
pause