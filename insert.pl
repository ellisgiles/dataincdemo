#!/usr/bin/perl
use strict;
use warnings;
use DBI;

my @ignore_strings = ( 'the', 'com', 'and', 'http', 'href', 'www', 'nofollow', 'rel', 'for', 'this', 
	'with', 'that', 'photo', 'from', 'per', 'new', 'photos', 'flickr', 'org', 'are', 'you', 'cannon', 'nikon',
	'instagram', 'del', 'photography', 'all', 'one', 'app', 'format', 'iphoneography', 'que', 'les',
	'calze', 'sant', 'was', 'jpg', 'but', 'her', 'she');

my $num_args = $#ARGV + 1;
if (($num_args > 2) || ($num_args == 0))
{
    print "\nUsage: insert.pl database.db [wordfile]\n";
    exit;
}
    
my $dbfile = $ARGV[0];
 
my $dsn      = "dbi:SQLite:dbname=$dbfile";
my $user     = "";
my $password = "";
my $db = DBI->connect($dsn, $user, $password, {
   PrintError       => 0,
   RaiseError       => 1,
   AutoCommit       => 1,
   FetchHashKeyName => 'NAME_lc',
});

my $fh;
my $isstdin = 0;
if (($num_args == 1) || ($ARGV[1] eq '-'))
{
	$fh = *STDIN;
	$isstdin++;
}
else
{
	my $filename = $ARGV[1];
	open($fh, '<:encoding(UTF-8)', $filename)
  		or die "Could not open file '$filename' $!";
}

my $photoinsert = $db->prepare('INSERT INTO photos (pid, url) VALUES (?, ?)');
my $insertword  = $db->prepare('INSERT OR IGNORE INTO words (word, count) VALUES (?, 0)');
my $getwordid   = $db->prepare('SELECT wid FROM words WHERE word=?');
my $insertmap   = $db->prepare('INSERT INTO map (pid, wid) VALUES (?, ?)');
my $updateword  = $db->prepare('UPDATE words SET count = count + 1 WHERE wid=?');

my $pid = 0;
my $count = 0;

while (my $row = <$fh>) {
  chomp $row;
  #print "$row\n";
  $pid++;
  
  $photoinsert->execute($pid, 'test');
  printf("%d\n", $pid);
  
  for (split ' ', $row) {
        
        my $word = $_;
        $word =~ s/\**//g; 
	$word =~ s/\[//g;
	$word =~ s/\]//g;

	$word =~ s/ies //;
	$word =~ s/ies$//;
	$word =~ s/s //;
	$word =~ s/s$//;


        #my $matched = first { /pattern/ } @ignore_strings;
        
        if ((not defined $word) || (length($word) < 3) || 
        	(grep( /^$word$/, @ignore_strings )) || ($word =~ /[0123456789]/ ) ) {
  			#print "found it";
		}
        else
        {
        	
        	#printf("word %d = %s\n", ++$count, $word);
        	$insertword->execute($word);
        	$getwordid->execute($word);
        	my $wid = $getwordid->fetchrow_hashref()->{wid};
        	$getwordid->finish();
        	#printf("$wid\n");
        	eval
        	{
        		$insertmap->execute($pid, $wid);
        		$updateword->execute($wid);
        	}
 		}        
        
  }
}

my $sth = $db->prepare('SELECT * FROM words ORDER BY count ASC');
$sth->execute();
while (my $row = $sth->fetchrow_hashref) {
   print "id: $row->{wid}  word: $row->{word}  count: $row->{count}\n";
}

close $fh unless $isstdin;

$db->disconnect;

