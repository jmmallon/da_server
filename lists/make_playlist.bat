@echo off
echo %date% %time% 1>> "J:\lists\make_playlist.log"
c:\cygwin\bin\bash.exe -l -c "/usr/bin/perl '/cygdrive/j/lists/make_playlist.pl' 1 2>&1" 1>> "J:\lists\make_playlist.log"
