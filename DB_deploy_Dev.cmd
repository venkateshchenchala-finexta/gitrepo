del deploy.txt
echo spool %cd%\spool.txt >deploy.txt
for /R %%i in (*.ddl,*.cnv,*.vw,*.fnc,*.prc,*.trg,*.inc,*.spc,*.sql) do echo @"%%i" >> deploy.txt
echo spool off >>deploy.txt
echo exit >>deploy.txt
PAUSE