@echo off
echo %date% %time% 1>> "J:\FTP\Delicious Agony\CPH\canvas.log"
c:\cygwin\bin\bash.exe -l -c "/usr/bin/perl '/cygdrive/j/FTP/Delicious Agony/CPH/canvas_show.pl' 2>&1" 1>> "J:\FTP\Delicious Agony\CPH\canvas.log"
