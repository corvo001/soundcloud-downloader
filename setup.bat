@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ================= CONFIG =================
set "ROOT=%~dp0"
set "VENV_DIR=%ROOT%.venv"
set "DEPS_DIR=%ROOT%deps"
set "FFMPEG_DIR=%DEPS_DIR%\ffmpeg"
set "FFMPEG_BIN=%FFMPEG_DIR%\bin"

set "FFMPEG_ZIP_URL=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
set "FFMPEG_ZIP=%DEPS_DIR%\ffmpeg-release-essentials.zip"
set "TMP_DIR=%DEPS_DIR%\_tmp_ffmpeg"
REM ==========================================

echo.
echo === [1/4] Comprobando Python ===
where python >nul 2>&1
if errorlevel 1 (
  echo ERROR: No encuentro "python" en PATH.
  echo Instala Python 3 x64 y marca "Add Python to PATH".
  exit /b 1
)

echo.
echo === [2/4] Creando entorno virtual .venv ===
if not exist "%VENV_DIR%\Scripts\python.exe" (
  python -m venv "%VENV_DIR%"
  if errorlevel 1 (
    echo ERROR: No pude crear el entorno virtual.
    exit /b 1
  )
) else (
  echo OK: El entorno virtual ya existe.
)

echo.
echo === [3/4] Instalando yt-dlp en el venv ===
"%VENV_DIR%\Scripts\python.exe" -m pip install -U pip >nul
"%VENV_DIR%\Scripts\python.exe" -m pip install -U yt-dlp
if errorlevel 1 (
  echo ERROR: Fallo instalando yt-dlp.
  exit /b 1
)

echo.
echo === [4/4] Instalando ffmpeg portable en deps\ffmpeg ===

if exist "%FFMPEG_BIN%\ffmpeg.exe" (
  echo OK: ffmpeg ya existe en "%FFMPEG_BIN%"
  goto :done_ffmpeg
)

if not exist "%DEPS_DIR%" mkdir "%DEPS_DIR%"

echo Descargando ffmpeg con curl.exe...
where curl.exe >nul 2>&1
if errorlevel 1 (
  echo ERROR: No encuentro curl.exe en tu sistema.
  echo En Windows 10/11 suele venir. Si no, actualiza Windows o instala curl.
  exit /b 1
)

curl.exe -L "%FFMPEG_ZIP_URL%" -o "%FFMPEG_ZIP%"
if errorlevel 1 (
  echo ERROR: curl.exe no pudo descargar ffmpeg.
  exit /b 1
)

if exist "%TMP_DIR%" rmdir /s /q "%TMP_DIR%"
mkdir "%TMP_DIR%"

echo Extrayendo ffmpeg ZIP con ZipFile .NET...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [IO.Compression.ZipFile]::ExtractToDirectory('%FFMPEG_ZIP%','%TMP_DIR%')"

if errorlevel 1 (
  echo ERROR: No pude extraer el ZIP de ffmpeg.
  exit /b 1
)

set "SRC_DIR="
for /d %%D in ("%TMP_DIR%\ffmpeg-*-essentials_build") do (
  set "SRC_DIR=%%D"
)

if not defined SRC_DIR (
  echo ERROR: No encontre la carpeta ffmpeg-*-essentials_build dentro del ZIP.
  echo Contenido de "%TMP_DIR%":
  dir "%TMP_DIR%"
  exit /b 1
)

if exist "%FFMPEG_DIR%" rmdir /s /q "%FFMPEG_DIR%"
mkdir "%FFMPEG_BIN%"

echo Copiando binarios de ffmpeg...
xcopy /e /i /y "%SRC_DIR%\bin\*" "%FFMPEG_BIN%\" >nul

if not exist "%FFMPEG_BIN%\ffmpeg.exe" (
  echo ERROR: ffmpeg.exe no aparecio en "%FFMPEG_BIN%".
  echo Revisa "%SRC_DIR%\bin"
  exit /b 1
)

del /q "%FFMPEG_ZIP%" >nul 2>&1
rmdir /s /q "%TMP_DIR%" >nul 2>&1

echo OK: ffmpeg instalado correctamente.

:done_ffmpeg
echo.
echo === SETUP COMPLETADO CON EXITO ===
echo Usa: run.bat "URL_DE_LA_PLAYLIST"
echo.

endlocal
exit /b 0
