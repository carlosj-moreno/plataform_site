# ─────────────────────────────────────────────────────────────────────────────
# exportar_fotos_temporal.ps1 — Corre la exportación de fotos del inventario
# a C:\FotosVehiculos\temporal (una por posición, nombres limpios, + formato).
# Lo invoca la tarea programada "BootWhatsapp exportar fotos" cada 30 min.
# El log guarda SOLO la última corrida (no crece): logs\exportar_fotos.log
# ─────────────────────────────────────────────────────────────────────────────
$Repo    = "C:\BootWhatsapp"
$Backend = Join-Path $Repo "Backend\bootwhatsapp"
$Py      = Join-Path $Backend ".venv\Scripts\python.exe"
$Log     = Join-Path $Repo "logs\exportar_fotos.log"

New-Item -ItemType Directory -Force -Path (Join-Path $Repo "logs") | Out-Null
Set-Location $Backend
& $Py (Join-Path $Repo "exportar_fotos_temporal.py") *> $Log
exit $LASTEXITCODE
