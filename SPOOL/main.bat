for %%i in ("start.bat","createSequence.bat","startImportToCsv.bat") do call %%i|| exit /b 1 rem подготовка DDL DCD для миграции


goto end
-----------
call "^start.bat"
call "createSequence.bat"
call "startImportToCsv.bat"
-----------

:end