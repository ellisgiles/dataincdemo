[erg@wrap2 I3]$ echo "select * from words where word in ('architecture', 'nature', 'art', 'food', 'dog', 'bike', 'bird', 'car', 'wedding', 'park', 'city', 'beach', 
'army', 'music', 'church', 'flower', 'water', 'military','people', 'national', 'world', 'travel', 'street', 'party', 'california', 'japan', 'river', 'lake', 'museum', 
'collection', 'school', 'island', 'garden', 'concert') order by count desc;" | sqlite3 t100k.db

86|park|1957
535|city|1802
122|art|1528
886|street|1285
41|travel|1241
505|party|1111
33|music|1058
1494|california|1031
724|people|1000
51|wedding|981
1052|japan|965
85|national|940
576|beach|894
181|world|889
748|garden|843
880|nature|829
678|car|816
395|lake|814
594|school|807
136|water|791
393|river|789
758|island|778
1160|museum|745
147|food|695
410|concert|600
937|dog|579
366|church|533
130|architecture|529
1051|bird|526
1221|bike|487
1215|collection|293
167|army|291
1697|military|189


Add URLs
 ./geturls.csh 100000  | ./addurls.pl t100k.db


Create Data
echo "select * from map;" | sqlite3 t100k.db | sed 's/|/ /g' | awk '{print $1 " " $2 " 1"}' > ooo
echo "select word from words order by ;" | sqlite3 t100k.db > ooowords


echo "select * from words where word in ('park', 'water', 'bird', 'car', 'food', 'art', 'army', 'music') order by count desc;" | sqlite3 t100k.db

echo "select distinct pid, url from photos where video=0 AND pid in (select pid from map where wid in (select wid from words where word in ('park', 'water', 'bird', 'car', 'food', 'art', 'army', 'music')));" | sqlite3 t100k.db

select count(pid) from photos where video=1;
249
delete from map where pid in (select pid from photos where video=1);

echo "select distinct pid, url from photos where video=0 AND pid in (select pid from map where wid in (select wid from words where word in ('park', 'water', 'bird', 'car', 'food', 'art', 'army', 'music')));" | sqlite3 t100k.db
  | sed 's/|/ /g' | awk '{print "wget " $2 " -O " $1".jpg"}' > downloader
  
select url from photos where pid = (x)
select words.word from words join map where words.wid=map.wid and map.pid=68

./similar.csh 13180


