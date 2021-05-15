#!/bin/sh
sftp jmmallon@oxygen.he.net << ENDFTP
cd DA/shows/$1
ls
lcd /cygdrive/j/FTP/Delicious\ Agony/ShowPlaylists
get *.m3u
lcd ../Joe/shows
get -r [A-Z]*
ENDFTP
