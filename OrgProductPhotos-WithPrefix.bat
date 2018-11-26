@ECHO OFF
SETLOCAL
SET "sourcedir="
PUSHD %sourcedir%

FOR /f "tokens=1-3 delims=_" %%a IN (
 'dir /b /a-d "*_*.*'
 ) DO ( 
MD %%b >>test.txt
MOVE "%%a_%%b_%%c" .\%%b\
)
POPD
GOTO :EOF