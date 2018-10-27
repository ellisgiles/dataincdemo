#!/usr/bin/perl
use strict;
use warnings;

my $num_args = $#ARGV + 1;
if ($num_args != 1)
{
    print "\nUsage: translate.pl wordfile\n";
    exit;
}
    
my $filename = $ARGV[0];
open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";

while (my $row = <$fh>) {
  chomp $row;
  my $res = `echo "$row" | fold -s -w 255 | trans -brief | tr '\n' ' '`;
  print "$res\n";
}

