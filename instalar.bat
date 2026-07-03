@echo off
REM ============================================================================
REM  instalar.bat - Despliegue de BootWhatsapp con un solo comando.
REM  Doble clic aqui (o ejecutalo). El script se encarga del resto:
REM    - 1a vez: crea deploy.config.ps1 y .env y los abre para que los llenes.
REM    - 2a vez: pide permisos de Administrador (UAC) y despliega todo.
REM ============================================================================
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy.ps1"
echo.
pause
