
@ECHO OFF

SETLOCAL EnableDelayedExpansion

FOR %%A IN (%*) DO (
    FOR /F "tokens=5 delims= " %%B IN ('DIR "%~dp0*.%%A" ^| find ".%%A"') DO ECHO %%B
)

ENDLOCAL
