set logname=%date:~0,2%%date:~3,2%%date:~6,8%_%time:~0,2%%time:~3,2%%time:~6,2%
set logname=%logname: =%

set pg_sql_path=%C:\Program Files\PostgreSQL\15\bin\psql.exe%
:: type nul > C:\Users\%username%\Desktop\SPOOL\TMP\log.txt
for /f "delims=" %%i in ('dir C:\Users\%username%\Desktop\SPOOL\REP /b/a-d') do (
echo TABLE: %%i >> C:\Users\%username%\Desktop\SPOOL\LOG\add_tables_%logname%.txt
"%pg_sql_path%" -h 185.209.162.254 -d demo -U postgres -p 5432 -f "C:\Users\%username%\Desktop\SPOOL\REP\%%i" >> C:\Users\%username%\Desktop\SPOOL\LOG\add_tables_%logname%.txt 2>>&1
)