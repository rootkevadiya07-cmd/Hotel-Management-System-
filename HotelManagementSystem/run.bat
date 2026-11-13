@echo off
setlocal
title Grand Azure Hotel Management System - Tomcat Server

echo ======================================================================
echo           GRAND AZURE HOTEL MANAGEMENT SYSTEM - SERVER LAUNCHER
echo ======================================================================
echo.

set "JAVA_HOME=C:\Program Files\Java\jdk-26.0.2"
set "CATALINA_HOME=C:\Users\Rahul Prasad\.gemini\antigravity\scratch\apache-tomcat-10.1.61"
set "CATALINA_BASE=%CATALINA_HOME%"

if not exist "%JAVA_HOME%\bin\java.exe" (
    echo [ERROR] Java JDK not found at %JAVA_HOME%
    pause
    exit /b 1
)

echo [OK] Java JDK found: %JAVA_HOME%
echo [OK] Apache Tomcat found: %CATALINA_HOME%
echo.
echo Application deployed at:
echo   - Local URL:   http://localhost:8080/
echo   - Context URL: http://localhost:8080/HotelManagementSystem/
echo.
echo ======================================================================
echo Starting Tomcat Server... Press Ctrl+C anytime to stop.
echo ======================================================================
echo.

cd /d "%CATALINA_HOME%\bin"
call catalina.bat run
pause
