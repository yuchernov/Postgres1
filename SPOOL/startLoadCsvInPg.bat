@echo off
@mode con cp select=1251 > nul

SETLOCAL EnableDelayedExpansion

set logname=%date:~0,2%%date:~3,2%%date:~6,8%_%time:~0,2%%time:~3,2%%time:~6,2%
set logname=%logname: =%
set "quote=WITH QUOTE E'\026'"
set "delim=DELIMITER E'\007'"
set pg_sql_path=%C:\Program Files\PostgreSQL\15\bin\psql.exe%
:: CONSTRAINT OFF EXCEPTION
for /f "delims=" %%i in ('dir C:\Users\%username%\Desktop\SPOOL\EXCEPTION_FOR_CSV_IMPORT\%lv_schema_name%\EXCEPTION.txt /b/a-d') do (
echo %%i >> C:\Users\%username%\Desktop\SPOOL\LOG\load_csv_%logname%.txt 2>&1
"%pg_sql_path%" -h 185.209.162.254 -d demo -U postgres -p 5432 -f "C:\Users\%username%\Desktop\SPOOL\EXCEPTION_FOR_CSV_IMPORT\%lv_schema_name%\%%i" >> C:\Users\%username%\Desktop\SPOOL\LOG\load_csv_%logname%.txt 2>>&1
)


:: CREATE FILE FOR PG
for /F "tokens=1-2 delims=." %%i in (C:\Users\%username%\Desktop\SPOOL\tables.txt) do (

::change qoute on "#" or "$"
for /f "delims=" %%a in ('type C:\Users\%username%\Desktop\SPOOL\EXCEPTION_FOR_CSV_IMPORT\CHANGE_QUOTE_FOR_PG.txt ^| findstr /x "%%j" ^| find /c /v ""') do (
if %%a==0 (for /f "delims=" %%d in ('type C:\Users\%username%\Desktop\SPOOL\EXCEPTION_FOR_CSV_IMPORT\CHANGE_QUOTE_FOR_PG_2.txt ^| findstr /x "%%j" ^| find /c /v ""') do (
if %%d==0 (set "excp_q=NaN") else (set "excp_q=%%j"
set "quote=WITH QUOTE E'\026'")
)
) else (set "excp_q=%%j"
set "quote=WITH QUOTE E'\026'")
)



::change delimeter on "#" or "@"
for /f "delims=" %%b in ('type C:\Users\%username%\Desktop\SPOOL\EXCEPTION_FOR_CSV_IMPORT\CHANGE_DELIMETER_FOR_PG.txt ^| findstr /x "%%j" ^| find /c /v ""') do (
if %%b==0 (for /f "delims=" %%c in ('type C:\Users\%username%\Desktop\SPOOL\EXCEPTION_FOR_CSV_IMPORT\CHANGE_DELIMETER_FOR_PG_2.txt ^| findstr /x "%%j" ^| find /c /v ""') do (
if %%c==0 (set "excp_d=NaN") else (set "excp_d=%%j"
set "delim=DELIMITER E'\007'")
)
) else (set "excp_d=%%j"
set "delim=DELIMITER E'\007'")
)



echo TRUNCATE TABLE %%i.%%j; > C:\Users\%username%\Desktop\SPOOL\PG\%%j.txt
if %%j==!excp_q! (if %%j==!excp_d! (echo COPY %%i.%%j FROM 'C:/CSV/%%j.csv' !quote! !delim! CSV encoding 'windows1251'; >> C:\Users\%username%\Desktop\SPOOL\PG\%%j.txt
) else (echo COPY %%i.%%j FROM 'C:/CSV/%%j.csv' !quote! %delim% CSV encoding 'windows1251'; >> C:\Users\%username%\Desktop\SPOOL\PG\%%j.txt)
) else if %%j==!excp_d! (echo COPY %%i.%%j FROM 'C:/CSV/%%j.csv' %quote% !delim! CSV encoding 'windows1251'; >> C:\Users\%username%\Desktop\SPOOL\PG\%%j.txt
) else (
echo COPY %%i.%%j FROM 'C:/CSV/%%j.csv' %quote% %delim% CSV encoding 'windows1251'; >> C:\Users\%username%\Desktop\SPOOL\PG\%%j.txt
)

::change for split file
for /f "delims=" %%l in ('dir "C:\CSV\SPLIT_FILE" /b ^| findstr "%%j_[0-9].csv" ^| find /c /v ""') do (
if %%l GTR 0 (
echo TRUNCATE TABLE %%i.%%j; > C:\Users\%username%\Desktop\SPOOL\PG\%%j.txt
for /f "delims=" %%q in ('dir "C:\CSV\SPLIT_FILE" /b ^| findstr "%%j_[0-9].csv"') do (
if %%j==!excp_q! (if %%j==!excp_d! (echo COPY %%i.%%j FROM 'C:/CSV/%%j.csv' !quote! !delim! CSV encoding 'windows1251'; >> C:\Users\%username%\Desktop\SPOOL\PG\%%j.txt
) else (echo COPY %%i.%%j FROM 'C:/CSV/SPLIT_FILE\%%q' !quote! %delim% CSV encoding 'windows1251'; >> C:\Users\%username%\Desktop\SPOOL\PG\%%j.txt)
) else if %%j==!excp_d! (echo COPY %%i.%%j FROM 'C:/CSV/SPLIT_FILE\%%q' %quote% !delim! CSV encoding 'windows1251'; >> C:\Users\%username%\Desktop\SPOOL\PG\%%j.txt
) else (
echo COPY %%i.%%j FROM 'C:/CSV/SPLIT_FILE\%%q' %quote% %delim% CSV encoding 'windows1251'; >> C:\Users\%username%\Desktop\SPOOL\PG\%%j.txt
))))

)





:: LOAD DATA
:: type nul > C:\Users\%username%\Desktop\SPOOL\TMP\log.txt
for /f "delims=" %%i in ('dir C:\Users\%username%\Desktop\SPOOL\PG /b/a-d') do (
echo %%i >> C:\Users\%username%\Desktop\SPOOL\LOG\load_csv_%logname%.txt 2>&1
for %%a in ("C:\Users\%username%\Desktop\SPOOL\PG\%%i") do (find /c /v "" "C:\CSV\%%~na.csv") >> C:\Users\%username%\Desktop\SPOOL\LOG\load_csv_%logname%.txt 2>&1
"%pg_sql_path%" -h 185.209.162.254 -d demo -U postgres -p 5432 -f "C:\Users\%username%\Desktop\SPOOL\PG\%%i" >> C:\Users\%username%\Desktop\SPOOL\LOG\load_csv_%logname%.txt 2>>&1
)

goto end

:: CONSTRAINT ON EXCEPTION
for /f "delims=" %%i in ('dir C:\Users\%username%\Desktop\SPOOL\EXCEPTION_FOR_CSV_IMPORT\%lv_schema_name%\LAST_UPDATE.txt /b/a-d') do (
echo %%i >> C:\Users\%username%\Desktop\SPOOL\LOG\load_csv_%logname%.txt 2>&1
"%pg_sql_path%" -h 185.209.162.254 -d demo -U postgres -p 5432 -f "C:\Users\%username%\Desktop\SPOOL\EXCEPTION_FOR_CSV_IMPORT\%lv_schema_name%\%%i" >> C:\Users\%username%\Desktop\SPOOL\LOG\load_csv_%logname%.txt 2>>&1
)
:end