@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
set "VENV_PY=%ROOT%.venv\Scripts\python.exe"
set "FFMPEG_BIN=%ROOT%deps\ffmpeg\bin"

if not exist "%VENV_PY%" (
  echo ERROR: No existe el entorno virtual. Ejecuta setup.bat primero.
  pause
  exit /b 1
)

if not exist "%FFMPEG_BIN%\ffmpeg.exe" (
  echo ERROR: No existe ffmpeg local. Ejecuta setup.bat primero.
  pause
  exit /b 1
)

REM Usa ffmpeg local solo para esta ejecucion
set "PATH=%FFMPEG_BIN%;%PATH%"

REM Si no se pasa URL como argumento, pedirla
if "%~1"=="" (
  echo.
  set /p PLAYLIST_URL=Introduce la URL de SoundCloud: 
) else (
  set "PLAYLIST_URL=%~1"
)

if "%PLAYLIST_URL%"=="" (
  echo ERROR: No se introdujo ninguna URL.
  pause
  exit /b 1
)

echo.
echo Descargando playlist:
echo %PLAYLIST_URL%
echo.

"%VENV_PY%" "%ROOT%sc_playlist.py" "%PLAYLIST_URL%"

echo.
echo Proceso terminado.
pause

endlocal
exit /b 0
