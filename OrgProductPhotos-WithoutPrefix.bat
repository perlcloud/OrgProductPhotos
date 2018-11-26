@ECHO OFF
SETLOCAL
SET "sourcedir="
PUSHD %sourcedir%

FOR /f "tokens=1-2 delims=_" %%a IN (
 'dir /b /a-d "*_*.*"'
 ) DO ( 
MD %%a
MOVE "%%a_%%b" .\%%a\
)
POPD
GOTO :EOF