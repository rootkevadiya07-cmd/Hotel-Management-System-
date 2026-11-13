@echo off
setlocal enabledelayedexpansion
title Grand Azure Hotel Management System - Database Setup

echo ======================================================================
echo           GRAND AZURE HOTEL MANAGEMENT SYSTEM - DATABASE SETUP
echo ======================================================================
echo.

set "MYSQL_EXE=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
set "SQL_FILE=%~dp0database\hotel_management.sql"

if not exist "%MYSQL_EXE%" (
    echo [ERROR] MySQL CLI not found at "%MYSQL_EXE%"
    echo Please ensure MySQL Server 8.0 is installed.
    pause
    exit /b 1
)

echo MySQL Client: "%MYSQL_EXE%"
echo SQL Script:   "%SQL_FILE%"
echo.
set /p MYSQL_PASS="Enter your MySQL 'root' password (press Enter if no password): "

echo.
echo Executing hotel_management.sql script...

if "%MYSQL_PASS%"=="" (
    "%MYSQL_EXE%" -u root < "%SQL_FILE%"
) else (
    "%MYSQL_EXE%" -u root -p"%MYSQL_PASS%" < "%SQL_FILE%"
)

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ======================================================================
    echo [SUCCESS] Database 'hotel_db' and tables created successfully!
    echo Seed data (rooms, users, bookings, staff) initialized.
    echo ======================================================================
) else (
    echo.
    echo [ERROR] Database setup failed with error code %ERRORLEVEL%.
    echo Please verify that your MySQL Server service is running and the password is correct.
)

echo.
pause
