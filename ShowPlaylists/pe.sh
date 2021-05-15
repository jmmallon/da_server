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
	show=`echo $shownum | awk -F'_' '{print $1}'`
	num=`echo $shownum | awk -F'_' '{print $2}'`
	date=`date -d "$date +7 days" +"%Y-%m-%d"`
	# echo -n $date? 
	# read shownum
	echo "J:\FTP\Delicious Agony\Don Cassidy\Shows\\$show $num\\$show $num.m3u" > $date-20-$show.m3u
	date2=`date -d "$date +2 days" +"%Y-%m-%d"`
	echo "$date $date2"
	ln $date-20-$show.m3u $date2-10-$show.m3u
	perl '/cygdrive/j/FTP/Delicious Agony/ShowPlaylists/filecheck.pl' $date-20-$show.m3u $date2-10-$show.m3u
done
