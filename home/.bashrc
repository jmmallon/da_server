if [ `/usr/bin/perl -e 'my @a=localtime; print $a[8];'` = 1 ]
then
	# export TZ=CST6CDT
	export TZ=EST5EDT
else
	export TZ=EST5EDT
fi
PATH=$PATH:/home/Joe
TERM=vt100;export TERM
umask 000
alias ld='ls -d G*'
alias rmd='rmdir * 2>/dev/null'
alias cr='cd ..;rmd;cd ..;rmd'
alias li="cd /cygdrive/j/lists;sed 's/::/|/g' library.txt | sort -t'|' -k 5,5rn -k 3,3 | sed 's/|/::/g' >/tmp/a;tail -5 library_live.txt;echo 'Ready?'; read n;vi /tmp/a;cp library_live.txt library_live.bak;cat /tmp/a >> library_live.txt; awk -F'::' '{print $1}' library_live.txt | perl timemeasure.pl"
alias vi=vim
alias vt='vi tmp/*[lm]'
alias mkdir='mkdir -p'
alias 755='chmod 755'
alias dl='cd "/cygdrive/c/Documents and Settings/Joe/My Documents/Downloads"'
alias dn='touch done'
# alias lt='/cygdrive/j/lists/length_test.pl'
alias co='perl /cygdrive/j/lists/crawlone.pl "$PWD"'
alias l='ls -l'
alias lt='ls -ltr'
alias e=exit
alias ll='ls -l'
alias sc='. ~/.bashrc'
alias scr='cd "/cygdrive/j/FTP/Delicious Agony/Default Stream/Scripts"'
alias cs='vi ~/.bashrc; . ~/.bashrc'
#alias t='cat *t | sed "s# / #/#g"| ~/caplines'
alias pf=cs
alias a='vi /tmp/a'
alias unrar='~/unrar'
alias cu='cat *u'
alias vu='vi *u'
alias link='~/link.sh'
alias ca='cat /tmp/a'
# alias ps='cd "/cygdrive/j/FTP/Delicious Agony/ProgScape/PSR PLAYLIST MP3S"'
alias u='cd "/cygdrive/j/FTP/Delicious Agony/upload"'
alias bc='perl "/cygdrive/j/FTP/Delicious Agony/upload/getbandcamp.pl"'
alias gs='perl "/cygdrive/j/FTP/Delicious Agony/upload/getshow.sh"'
alias ps='perl "/cygdrive/j/FTP/Delicious Agony/upload/getprogstreaming.pl"'
# alias sc='perl "/cygdrive/j/FTP/Delicious Agony/upload/getsoundcloud.pl"'
alias det='perl "/cygdrive/j/FTP/Delicious Agony/upload/details.pl"'
alias detu='perl "/cygdrive/j/FTP/Delicious Agony/upload/details_m3u.pl"'
alias len='perl "/cygdrive/j/FTP/Delicious Agony/upload/length.pl"'
alias up='cd "/cygdrive/j/FTP/Delicious Agony/upload"'
alias j='cd "/cygdrive/j/FTP/Delicious Agony/Joe"'
alias joe='cd "/cygdrive/j/FTP/Delicious Agony/Joe"'
alias show='cd "/cygdrive/j/FTP/Delicious Agony/Joe/shows"'
alias don='cd "/cygdrive/j/FTP/Delicious Agony/Don Cassidy"'
alias mus='cd "/cygdrive/j/Music"'
alias p='cd "/cygdrive/j/Prog2k Artists"'
alias pl='cd "/cygdrive/j/FTP/Delicious Agony/ShowPlaylists"'
alias fc='cd "/cygdrive/j/FTP/Delicious Agony/ShowPlaylists"; perl filecheck.pl'
alias c=fc
alias fj='perl "/cygdrive/j/FTP/Delicious Agony/ShowPlaylists/filecheck-joe.pl"'
alias fch='perl "/cygdrive/j/FTP/Delicious Agony/ShowPlaylists/filecheck.pl"'
alias lib='cd "/cygdrive/j/FTP/Delicious Agony/Library"'
alias promo='cd "/cygdrive/j/FTP/Delicious Agony/Library/Promos"'
alias promos='cd "/cygdrive/j/FTP/Delicious Agony/Library/Promos"'
alias id='cd "/cygdrive/j/FTP/Delicious Agony/Library/IDs"'
alias ident='vi "/cygdrive/j/FTP/Delicious Agony/Library/IDs/idents.ini"'
alias int='cd "/cygdrive/j/FTP/Delicious Agony/Library/Interviews"'
alias ids='cd "/cygdrive/j/FTP/Delicious Agony/Library/IDs"'
alias list='cd "/cygdrive/j/lists"'
alias 7='cd "/cygdrive/j/lists"; perl new_playlist.pl 7'
alias lis='vi /cygdrive/j/lists/Stainless.txt'
alias liu='vi /cygdrive/j/lists/Unearthed.txt'
alias lif='vi /cygdrive/j/lists/Freakout.txt'
alias lisp='vi /cygdrive/j/lists/Spectrum.txt'
alias lie='vi /cygdrive/j/lists/Electronic.txt'
alias h='history | tail -15'
alias hi='history'
alias hg='history | grep -i'
alias ag='alias | grep -i'
alias tag='id3v2 -l'
alias tagd='id3v2 -D'
alias taga='id3v2 -l *3'
alias ty='id3v2 -l *3 | grep TYE'
alias tags='id3v2 -l'
alias art='id3v2 -a'
alias al='id3v2 -A'
alias tn='id3v2 -T'
alias retn='mytn=$tn;for i in *3; do mytn=`expr $mytn + 1`; if [ $mytn -lt 10 ]; then mytn="0$mytn"; fi;tn $mytn "$i"; done'
alias retnp='for i in *3; do echo "$i"; read tn; tn $tn "$i"; done'
alias yr='id3v2 -y'
alias reyr='for i in *3; do echo "$i"; read yr; yr $yr "$i"; done'
alias realyr='for i in *3; do echo "$i";echo Album; read al; echo Year; read yr; id3v2 -A "$al" -y $yr "$i"; done'
alias gen='id3v2 -g'
alias gn='id3v2 -g'
alias 92='id3v2 -g 92 *3'
alias 9='id3v2 -g 9 *3'
alias name='id3v2 -t'
alias cap='~/capitalize'
alias p2k='~/p2k'
#alias tr='/home/Joe/tagredo'
alias trm='/home/Joe/tagmar'
alias retag='/home/Joe/retag'
alias tr='/home/Joe/tagrename_new'
alias trnm='/home/Joe/trnm'
alias trh='/home/Joe/tagrename_holiday'
alias trn='/home/Joe/tagrename_new'
alias trd='/home/Joe/tagrename_don'
alias d='sd;/home/Joe/tagrename_don'
alias ts='/home/Joe/tagrename_new "Stratovarius"'
alias trnl='/home/Joe/tagrename_new_lc'
alias g='/home/Joe/genre_done'
alias cn='/home/Joe/copy_nodash'
alias c0='/home/Joe/copy 0 y'
alias psl='/home/Joe/progloop'
alias pslr='/home/Joe/progloop_remaster'
alias psr='/home/Joe/progscape_remaster'
alias f='sftp jmmallon@oxygen.he.net'
alias wf='ftp deliciousagony.com'
alias pst='/home/Joe/progscape'
alias tp='tr ps'
alias pg='/home/Joe/progscape'
alias pstny='/home/Joe/progscape_no_year'
alias tg='/home/Joe/tagredo "Greg Segal"'
alias n='taga | grep --text "TI*T2"'
alias ar='taga | grep --text "TPE*1"'
alias nn='taga | grep "Title" | grep -v TIT'
alias dup='id3v2 -y 9999'
alias dupa='id3v2 -y 9999 *3'
alias dt='ds; tr'
alias st='sd; tr'
alias sy='sd; tr y'
alias s-='sd; tr y -'
alias tra='for i in *; do cd "$i";tr;cd ..; done'
alias std='for i in *; do cd "$i";st;cd ..; done'
alias sd='for i in *3; do fn=`echo $i | sed "s/ / - /"`; mv "$i" "$fn"; done'
alias ds='for i in *3; do fn=`echo $i | sed "s/-/ - /g"`; mv "$i" "$fn"; done'
alias t='for i in *3; do echo "Doing $i"; fn=`echo $i | sed -e "s/.mp3//i" -e "s/^... *//" -e "s/_ /: /" -e "s/- /: /" -e "s/-\$/?/"`; fn=`~/capitalize "$fn"`; id3v2 -g 92 -t "$fn" "$i"; done; touch done; taga | grep TIT'
alias tlc='for i in *3; do echo "Doing $i"; fn=`echo $i | sed -e "s/.mp3//i" -e "s/^... *//" -e "s/_ /: /" -e "s/- /: /" -e "s/-\$/?/"`; fn=`~/capitalize_lc "$fn"`; id3v2 -g 92 -t "$fn" "$i"; done; touch done; taga | grep TIT'
alias sp='for i in *3; do echo "Doing $i"; fn=`echo $i | sed -e "s/.mp3//i" -e "s/^.* \-//" -e "s/_ /: /" -e "s/^[^ ]* //" -e "s/- /: /" -e "s/-\$/?/"`; fn=`~/capitalize "$fn"`; id3v2 -g 92 -t "$fn" "$i"; done; touch done; taga | grep TIT'
alias dash='for i in *mp3; do echo "Doing $i"; fn=`echo $i | sed -e "s/.mp3//" -e "s/^.* \- //" -e "s/_ /: /" -e "s/- /: /"`; fn=`~/capitalize "$fn"`; id3v2 -g 92 -t "$fn" "$i"; done; touch done; taga | grep TIT'
alias spnc='for i in *mp3; do echo "Doing $i"; fn=`echo $i | sed -e "s/.mp3//" -e "s/^.* \-//" -e "s/^[^ ]* //" -e "s/_ /: /" -e "s/- /: /" -e "s/-\$/?/"`; id3v2 -g 92 -t "$fn" "$i"; done; touch done; taga | grep TIT'
alias dont='echo Year; read yr; for i in *3 ;do n=`echo $i | sed -e "s/^[^\-]*-//" -e "s/^[^\-]*-//" -e "s/ -.*//" -e "s/- /: /" -e "s/.mp3//"`; n=`~/capitalize "$n"`; id3v2 -t "$n" -g 92 -y $yr "$i"; done; touch done; n'
alias r='perl "/cygdrive/j/FTP/Delicious Agony/upload/rename.pl"'
alias ren='perl "/cygdrive/j/FTP/Delicious Agony/upload/rename.pl"'
#alias capren='for i in *3; do n=`echo $i | sed -e "s/.mp3//"`; n=`~/capitalize "$n"`; mv "$i" "$n.mp3";done;ls'
alias capt='for i in *3; do echo "Doing $i"; fn=`echo $i | sed -e "s/.mp3//i" -e "s/^... *//"`; fn=`~/capitalize "$fn"`; id3v2 -g 92 -t "$fn" "$i"; done; touch done; taga | grep TIT'
alias r2='retn;capt'
alias rentn='for i in *3;do echo $i;read n; mv "$i" "$n. $i";done'
alias d2='for i in *3;do  mv "$i" "a$i";done'
alias dozap='for i in *;do echo "$i";ls "$i"; read yn; if [ "x$yn" != "xn" ]; then cd "$i";st;cd ..; fi; done'
alias nid='name "Station ID"'
rt () {
	for i in "$@"
	do
		a=`echo $i | sed -e 's/ \-.*//' -e 's/ Of / of /' -e 's/ And / and /'`
		n=`echo $i | sed -e 's/.*\-//' -e 's/.mp3//'`
		id3v2 -a "$a" "$i"
		id3v2 -t "$n" "$i"
	done
}
rn () {
	for i in "$@"
	do
		a=`echo $i | sed -e 's/^[^ ]* //' -e 's/.mp3//' -e 's/- /: /'`
		a=`perl -e '$n = $ARGV[0]; $n =~ s/([^\w\047][a-z])/uc($1)/ge; print ucfirst($n);' "$a"`
		id3v2 -t "$a" "$i"
	done
}
alias rna="rn *3"
ra () {
	al=`echo $1 | sed -e 's/^.......//' -e 's@/$@@'`
	id3v2 -A "$al" "$1"/*3
}

gomb () {
	id3v2 -D $1
	id3v2 -A "Glass Onyon's Muzik Bizarre" $1
	id3v2 -a "Glass Onyon" $1
	id3v2 -y `date '+%Y'` $1
	id3v2 -g 92 $1
	id3v2 -T 00 $1
	id3v2 -t "Muzik Bizarre Show $2" $1
}

vf () {
	vi "$@"
	fch "$@"
}

dm () {
	  cat $1/*u
	  read n
	  if [ $n = "r" ]
	  then
		  rm -rf "$1"
	  else
	  	mv $1 ..
	  	vi ../$1/*u
	  	fch ../$1/*u
  	  fi
}

si () {
	location="/cygdrive/j/FTP/Delicious Agony/Library/IDs"
	for id in "$@"
	do
        	a=`echo $id | awk -F' - ' '{print $1}' | sed 's/ Of / of /'`
        	n=`echo $id | awk -F' - ' '{print $NF}' | sed 's/\.mp3//'`
		id3v2 -D "$id"
		id3v2 -t "$n" -a "$a" "$id"
		id3v2 -l "$id"
		read n
		mv "$id" "$location"
		echo >> "$location/idents.ini"
		echo "$id" >> "$location/idents.ini"
	done
	cd "$location"
	cp idents.ini idents.bak
	vim idents.ini
}

sis () {
        if [[ -z $1 ]]
	then
		echo "Need a file!"
		return 1
	else
        	id=$1
        	a=`echo $id | awk -F' - ' '{print $1}' | sed 's/ Of / of /'`
        	n=`echo $id | awk -F' - ' '{print $NF}' | sed 's/\.mp3//'`
		id3v2 -D "$id"
		id3v2 -t "$n" -a "$a" "$id"
		id3v2 -l "$id"
		mv "$id" "/cygdrive/j/FTP/Delicious Agony/Library/IDs"
		cd "/cygdrive/j/FTP/Delicious Agony/Library/IDs"
		cp shows.ini shows.bak
		read n
		echo >> shows.ini
		echo "[$a]" >> shows.ini
		echo "$id" >> shows.ini
		vim shows.ini
	fi
}

dir () {
        if [[ -z $1 ]]; then echo "Need a directory!"; return 1; else
        do=$1
        d=`echo $do | sed 's/ By Muro//g'`
        a=`echo $d | awk -F' - ' '{print $1}'`
        l=`echo $d | awk -F' - ' '{print $NF}' | sed 's/ (.*//'`
        y=`echo $d | awk -F'(' '{print $NF}' | awk -F')' '{print $1}'`
        mv "$do" "$a"
        mkdir "$a/$y - $l"
        echo "a - $a; l - $l; y - $y"
        fi
}

