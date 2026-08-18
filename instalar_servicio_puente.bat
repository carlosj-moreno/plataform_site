@echo off
REM ---------------------------------------------------------------------------
REM instalar_servicio_puente.bat - Doble clic para convertir el puente de
REM WhatsApp en un servicio de Windows (arranca solo con el servidor y se
REM reinicia solo si se cae).
REM
REM Windows PEDIRA PERMISO DE ADMINISTRADOR: registrar un servicio lo exige.
REM Acepta el aviso y deja que termine.
REM
REM OJO: reinicia el puente. Si hay una vinculacion por QR a medias, esperala.
REM ---------------------------------------------------------------------------
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','%~dp0instalar_servicio_puente.ps1'"
