#!/bin/bash
if [ $# -ne 2 ]
then
	echo "Usage: $0 DATE LASTDATE"
	exit
fi

date=$1
file=$2
oldmonth=0
cat $file | while read shownum
do
	date=`date -d "$date +7 days" +"%Y-%m-%d"`
	month=`date -d $date +"%m"`

	# Skip 2nd week of each month

	if [ $month -ne $oldmonth ]
	then
		oldmonth=$month
		stop=1
	elif [ $stop -eq 1 ]
	then
		stop=0
		continue
	fi
	echo "J:\FTP\Delicious Agony\ProgScape\PSR_0$shownum.mp3" > $date-15-Progscape.mp3
	perl '/cygdrive/j/FTP/Delicious Agony/ShowPlaylists/filecheck.pl' $date-15-ProgScape.mp3
done
