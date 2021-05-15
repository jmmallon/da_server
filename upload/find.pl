#!/usr/bin/perl
$| = 1;
use File::Find;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;


find(\&wanted, @ARGV);
sub wanted {
	if (/.mp3$/ && lstat($_) && int(-M _) < 3) { print "$File::Find::name\n"; }
}
