@echo off
REM ============================================================================
REM  iniciar.bat - Comando de ACTIVACION: arranca todo y lo deja sirviendo.
REM  (Backend :8000, Frontend :8080, Engine :3001)
REM  Doble clic aqui, o ejecutalo. Si es la PRIMERA vez en este equipo, usa
REM  primero  instalar.bat  (construye todo).
REM ============================================================================
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0native\local.ps1' stop; & '%~dp0native\local.ps1' start; & '%~dp0native\local.ps1' status"
echo.
echo  Abre:  http://localhost:8080
echo.
pause
