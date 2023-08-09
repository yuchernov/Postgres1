for /F "tokens=1-2 delims=." %%i in (C:\Users\Yury\Desktop\SPOOL\tables.txt) do tableddl.bat %%i %%j
rem в table txt мы кладем таблицы, которые необходимы миграции