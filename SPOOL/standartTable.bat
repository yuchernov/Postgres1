type nul > C:\Users\%username%\Desktop\SPOOL\tables_exception.txt
for %%a in ("C:\Users\%username%\Desktop\SPOOL\EXCEPTION_FOR_CSV_IMPORT\*") do (echo %%~na>> C:\Users\%username%\Desktop\SPOOL\tables_exception.txt)

for /F "tokens=1-2 delims=." %%i in (C:\Users\%username%\Desktop\SPOOL\tables.txt) do (
for /f "delims=" %%a in ('type C:\Users\%username%\Desktop\SPOOL\tables_exception.txt ^| findstr /x "%%j" ^| find /c /v ""') do (
if %%a==0 (
for /f "delims=" %%b in ('type C:\Users\%username%\Desktop\SPOOL\tables_big.txt ^| findstr /x "%%j" ^| find /c /v ""') do (
if %%b==0 (importToCsv.bat %%i %%j "" "" "" -1))
) else (
SQLPLUS OT/wertuaL777@testdb @EXCEPTION_FOR_CSV_IMPORT\%%j.sql
)
)
)
