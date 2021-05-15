#!/bin/bash
if [ $# -ne 2 ]
then
	echo "Usage: $0 DATE LASTDATE"
	exit
fi

date=$1
file=$2
cat $file | while read shownum
do
	date=`date -d "$date +7 days" +"%Y-%m-%d"`
	# echo -n $date? 
	# read shownum
	echo "J:\FTP\Delicious Agony\Michael\Sonic Kaleidoscope\Show$shownum\MSK$shownum.m3u" > $date-17-MSK.m3u
	date2=`date -d "$date +R3day" +"%Y-%m-%d"`
	ln $date-17-MSK.m3u $date2-15-MSK.m3u
	perl '/cygdrive/j/FTP/Delicious Agony/ShowPlaylists/filecheck.pl' $date-17-MSK.m3u $date2-15-MSK.m3u
done
