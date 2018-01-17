#!/bin/bash
P=~/.nya;
while read str
do
category=`echo $str|cut -d '|' -f1`
key=`echo $str|cut -d '|' -f2`
url=`echo $str|cut -d '|' -f3`
animepath=`echo $str|cut -d '|' -f4`
echo -ne "\033[1m"'\E[37;10m'"$category"
tput sgr0

wget -O - -q "http://www.nyaatorrents.org/?page=rss&catid=1&subcat=11&term=$key"| grep -E '(title>|link>)'|sed 's/<title>\|.avi\|.mp4\|amp;\|.mkv\|.wmv\|^[ \t]*//g'|tail -n +3|tr -d '\n'|sed -e 's/<\/link>/\n/g' -e 's/<\/title><link>/|/g'|head -n -1|
while read  s
do   
	a=`echo $s|cut -d '|' -f1`
	b=`echo $s|cut -d '|' -f2`
	c=`sqlite3 "$P/test.db" "select name from torrents where name =\"$a\""`
	if [ -z "$c" ]; then
		sqlite3 "$P/test.db"  "insert into torrents (name,link,category) values (\"$a\",\"$b\",\"$category\");"
	fi
done

wget -qc  "$url" -O -|grep -o "download.php?id="..... |sort -u|
while read  s 
do
	c=`sqlite3 "$P/test.db" "select link from archives where link =\"$s\""`
	if [ -z "$c" ]; then 
	sqlite3 "$P/test.db"  "insert into archives (category,link) values (\"$category\",\"$s\");"
	wget -q --content-disposition -P "$P/archives" "http://fansubs.ru/forum/$s"
	ls "$P/archives/"|
	while read s1
	do
		aunpack -q -X "$P/tmpsubs" "$P/archives/$s1" > /dev/null
		rm "$P/archives/$s1"
	done
	ls "$P/tmpsubs/"| 
	while read sl
	do
		c=`echo "$sl"|sed -e 's/.PrCd././' -e 's/.ass//' `
		d=`sqlite3 "$P/test.db" "select link from torrents where name =\"$c\""`
		if [ "$d" ]
		then 
		wget "$d" -qO "$P/torrents/$c.torrent"
  		cp "$P/torrents/$c.torrent" "$animepath$c.torrent"
		cp "$P/tmpsubs/$sl" "$animepath"
		# добавить не цп а мв и чтобы проверяло наличие файлов)
		echo "$c"|sendsms
		echo "$c">>~/.conky/series
		echo "$c"
		fi
	done
	mv "$P/tmpsubs/"* "$P/allshit/$category/"
	fi
done

echo -e "\033[1m"'\E[33;10m'"\tcomplete"
tput sgr0 

done<"$P/config"
datee=`date +%y'\'%m'\'%d' '%H:%M`
c=`diff "$P/test.db" "$P/last.db"`
if [ "$c" ] 
then
cp "$P/last.db" "$P/$datee.db"
cp "$P/test.db" "$P/last.db"
fi
