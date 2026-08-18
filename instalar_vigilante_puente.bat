@echo off
REM ---------------------------------------------------------------------------
REM instalar_vigilante_puente.bat - Doble clic para que el sistema vigile solo
REM el puente de WhatsApp cada 5 minutos y lo levante si se cae.
REM NO pide permiso de Administrador.
REM ---------------------------------------------------------------------------
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0instalar_vigilante_puente.ps1"
