@ECHO OFF

::Set & Start DailyLOG File
::LOG KEY  -  +start  -end  *?note  !success  Xerror
SET "logfile=%cd%\ProductImageData_Log.txt"
ECHO + %date% %time%	%~n0%~x0	Started >>%logfile%
::Sets counter for Log
SET /a count = 0

::Set Locations
SET "FileSource=%cd%"
SET "DataFile=ProductImageData.txt"
SET "ImageFolder="
SET "TempFolder=Temp_ProductImageData"
SET "BackupPath=%FileSource%\%TempFolder%\%DataFile%"
SET "FilePath=%FileSource%\%DataFile%"

::Counts how many lines are in the original txt file "ProductImageData.txt"
SET /a OrgActLines=0
FOR /F %%p IN ('Find "" /v /c ^< "%FilePath%"') DO Set /a OrgActLines=%%p
::Removes 1 line from the count to exclude the headers
SET /a OrgActLines=%OrgActLines%-1
ECHO * %date% %time%	%~n0%~x0	%OrgActLines% lines in original ProductImageData.txt >>%logfile%

::Creates a temp backup of the original txt file
MD "%FileSource%\%TempFolder%"
MOVE "%FileSource%\%DataFile%" "%BackupPath%"

::Creates a new txt file with the appropriate headers
ECHO "Path"_"FileName"_"ExportDate"_"MatchID"_AngleCodePART >>"%FilePath%"

::Looks for every jpg in the image folder and...
::adds a record for each image to the txt file
FOR /R "%ImageFolder%" %%i IN (*.jpg) DO (
	ECHO "%%~dpi"_"%%~ni%%~xi"_"%%~ti"_%%~ni  >>"%FilePath%"
	SET /a count += 1
	ECHO %%~ni%
)

::Logs the number of files discovered by the count.
::If there are less than 3000 photos found, thats strange, however we dont stop the script. This threshold can be adjusted.
IF %count% GEQ 3000 ECHO * %date% %time%	%~n0%~x0	%count% images found >>%logfile%
IF %count% LSS 2900 ECHO ? %date% %time%	%~n0%~x0	%count% images found >>%logfile%

::Counts the current txt file and compares it to the original 
SET /a CurActLines=0
FOR /F %%g IN ('Find "" /v /c ^< "%FilePath%"') DO Set /a CurActLines=%%g
SET /a CurActLines=%CurActLines%-1

::Chooses to continue action or roll back changes
::If the new txt file shows less photos than we had originally, we roll back becasue photos are usually not del
IF %CurActLines% LSS %OrgActLines% GOTO rollback
::If the new txt file shows 0, something clearly failed so rollback.
::This is needed becasue sometimes the 0 will match 0 lines on the original version becasue the counting script fails.
IF %CurActLines% EQU 0 GOTO rollback
IF %CurActLines% GEQ %OrgActLines% GOTO continue

:rollback:
DEL "%FileSource%\%DataFile%"
COPY "%BackupPath%" "%FileSource%\%DataFile%"
RMDIR /S /Q "%FileSource%\%TempFolder%"
ECHO X %date% %time%	%~n0%~x0	New DataFile has less records (%CurActLines%) then original (%OrgActLines%) - original file returned >>%logfile%
SET "LoadFail=1"
GOTO end

:continue:
RMDIR /S /Q "%FileSource%\%TempFolder%"
::Logs the number of lines added the the txt file
SET /a ActLines=0
FOR /F %%j IN ('Find "" /v /c ^< "%FilePath%"') DO Set /a ActLines=%%j
SET /a ActLines=%ActLines%-1
::Logs the number of lines added to the txt file
IF %ActLines% GEQ 3000 ECHO * %date% %time%	%~n0%~x0	%ActLines% lines in current ProductImageData.txt >>%logfile%
IF %ActLines% LSS 2900 ECHO ? %date% %time%	%~n0%~x0	%ActLines% lines in current ProductImageData.txt >>%logfile%
::Checks if the files discovered matches the number of lines added 
IF %count% NEQ %ActLines% ECHO X %date% %time%	%~n0%~x0	ImageCount and DataLines Mismatch >>%logfile%
::In case of some failure where the script finished successfully but the line count is below the expected threshold, log a warning.
IF %ActLines% LSS 2900 ECHO X %date% %time%	%~n0%~x0	Check ImageCount and DataLine numbers >>%logfile%
SET "LoadFail=0"
GOTO end

:end:
ECHO - %date% %time%	%~n0%~x0	Ended >>%logfile%
