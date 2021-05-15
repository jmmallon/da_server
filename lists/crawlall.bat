@echo off
echo %date% %time% 1>> j:\lists\batch.log
c:\cygwin\bin\bash.exe -l -c "/usr/bin/perl /cygdrive/j/lists/crawl.sh" 1>> j:\lists\batch.log
