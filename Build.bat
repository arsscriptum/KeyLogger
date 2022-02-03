@echo off
setlocal EnableDelayedExpansion

:: ==============================================================================
:: 
::      ｂｕｉｌｄ．ｂａｔ
::
::      𝒸𝓊𝓈𝓉ℴ𝓂 𝒷𝓊𝒾𝓁𝒹 𝓈𝒸𝓇𝒾𝓅𝓉 𝒻ℴ𝓇 ℊℯ𝓉𝒶𝒹𝓂
::
:: ==============================================================================
::   arsccriptum - made in quebec 2020 <guillaumeplante.qc@gmail.com>
:: ==============================================================================

goto :init

:init
    set "__scripts_root=%AutomationScriptsRoot%"
    call :read_script_root development\build-automation  BuildAutomation
    set "__script_file=%~0"
    set "__target=%~1"
    set "__script_path=%~dp0"
    set "__makefile=%__scripts_root%\make\make.bat"
    set "__lib_date=%__scripts_root%\batlibs\date.bat"
    set "__lib_out=%__scripts_root%\batlibs\out.bat"
    ::*** This is the important line ***
    set "__build_cfg=%__script_path%buildcfg.ini"
    set "__build_cancelled=0"
    goto :validate


:header
    echo. %__script_name% v%__script_version%
    echo.    This script is part of codecastor build wrappers.
    echo.
    goto :eof

:error_missing_script
    echo.**************************************************
    echo.This script is part of arsscriptum build wrappers.
    echo.**************************************************
    echo.
    echo. YOU NEED TO HAVE THE BuildAutomation Scripts setup on you system...
    echo. https://github.com/arsscriptum/BuildAutomation
    goto :eof


:read_script_root
    set regpath=%OrganizationHKCU::=%
    for /f "tokens=2,*" %%A in ('REG.exe query %regpath%\%1 /v %2') do (
            set "__scripts_root=%%B"
        )
    goto :eof

:validate
    if not defined __scripts_root          call :header_err && call :error_missing_path __scripts_root & goto :eof
    if not exist %__makefile%  call :error_missing_script "%__makefile%" & goto :eof
    if not exist %__lib_date%  call :error_missing_script "%__lib_date%" & goto :eof
    if not exist %__lib_out%  call :error_missing_script "%__lib_out%" & goto :eof

    goto :build


:: ==============================================================================
::   Build x64 Release
:: ==============================================================================
:build_asm
    
    call %__lib_out% :__out_n_l_grn "[x] "
    mkdir %cd%\bin
    call %__lib_out% :__out_d_cya "created %cd%\bin"
    call %__lib_out% :__out_n_d_yel "[i] "
    call %__lib_out% :__out_l_cya "Using Flat Assembler C:\Programs\FlatAssembler\FASM.EXE"
    call %__lib_out% :__out_n_d_yel "[i] "
    call %__lib_out% :__out_l_cya "Building src/kl.asm to bin/kl.exe"
    "C:\Programs\FlatAssembler\FASM.EXE" %cd%\src\kl.asm %cd%\bin\kl.exe
    call %__lib_out% :__out_n_d_yel "[i] "
    call %__lib_out% :__out_d_red "Fasm Done"
    goto :eof



:: ==============================================================================
::   Build
:: ==============================================================================
:build
    
    call %__lib_out% :__out_n_l_grn "[x] "
    rmdir /s /q bin
    call %__lib_out% :__out_d_cya "deleted %cd%\bin"
    call :build_asm
    goto :finished


:finished
    call %__lib_out% :__out_n_d_yel "[i] "
    call %__lib_out% :__out_n_d_red "output "
    
    dir /l /b /q %cd%\bin\kl.exe
    call %__lib_out% :__out_n_l_grn "Done"
    
    goto :eof
