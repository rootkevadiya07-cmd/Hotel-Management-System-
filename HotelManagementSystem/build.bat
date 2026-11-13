@echo off
cd /d "%~dp0"
echo ========================================================
echo Compiling Hotel Management System...
echo ========================================================
powershell -ExecutionPolicy Bypass -File "%~dp0compile.ps1"
