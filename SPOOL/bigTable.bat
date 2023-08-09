
for /F "tokens=1-2 delims=." %%i in (C:\Users\%username%\Desktop\SPOOL\tables_big.txt) do (
for /L %%a in (0,1,4) do (
importToCsv.bat %%i %%j "where mod(" ",5) = " %%a %%a
)
)