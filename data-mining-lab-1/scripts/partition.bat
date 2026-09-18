@echo off
setlocal enabledelayedexpansion
set SRC=..\raw\sales
set DST=..\processed\sales

for %%f in (%SRC%\SALES_*.csv) do (
    for /f "tokens=2,3 delims=_" %%a in ("%%~nf") do (
        set store=%%a
        set datepart=%%b
        set yr=!datepart:~0,4!
        set mo=!datepart:~4,2!
        set outdir=%DST%\store_id=!store!\year=!yr!\month=!mo!
        if not exist "!outdir!" mkdir "!outdir!"
        copy "%%f" "!outdir!\" >nul
    )
)
echo done partitioning