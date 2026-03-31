@echo off
setlocal

set "SRC=%~dp0"
set "OUT=%SRC%output"

if not exist "%OUT%" mkdir "%OUT%"

for %%f in ("%SRC%*.md") do (
    echo Converting %%~nf.md ...
    pandoc "%%f" -o "%OUT%\%%~nf.docx"
    if errorlevel 1 (
        echo FAIL: %%~nf.md
    ) else (
        echo OK: %%~nf.docx
    )
)

echo.
echo Done. Files saved to %OUT%
pause
