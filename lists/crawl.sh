#!/usr/bin/sh
cd /cygdrive/j/lists
cp "/cygdrive/j/FTP/Delicious Agony/Library/IDs/idents.ini" "/cygdrive/j/FTP/Delicious Agony/Library/IDs/shows.ini" /cygdrive/j/lists

/usr/bin/perl crawler.pl $1 > crawler.log 2>&1

/usr/bin/zip -9 list.zip idents.ini shows.ini songlist.sql Electronic.txt Freakout.txt Spectrum.txt Superstars.txt Stainless.txt Unearthed.txt >> crawler.log 2>&1

# cp list.zip "../FTP/Delicious Agony/Joe/Crawler"
# ssh jmmallon@oxygen.he.net "/home/jmmallon/DA/newlist.new 2>&1 > /home/jmmallon/DA/newlist.log"

scp -P 2222 list.zip deliciou@deliciousagony.com:/home4/deliciou/public_html/.suite/search/.nl
ssh deliciou@deliciousagony.com /home4/deliciou/public_html/.suite/search/.nl/copy
