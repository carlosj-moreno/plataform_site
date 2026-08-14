@echo off
REM ---------------------------------------------------------------------------
REM actualizar.bat - Doble clic para poner al dia todo el sistema.
REM Llama a actualizar.ps1, que trae el codigo de GitHub, migra, compila y
REM publica. Windows pedira permiso de Administrador solo al final.
REM ---------------------------------------------------------------------------
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0actualizar.ps1"
