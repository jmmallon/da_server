#!/usr/bin/perl

use MP3::Tag;
use MP3::Info;

$| = 1;

foreach my $file (@ARGV) {
	open(FI, "$file") || die ("$file - $!");
	chomp(my @list = <FI>);
	close(FI);
	foreach $file (@list) {
		if ($file =~ /\.mp3$/i) {
			my $info = get_mp3info($file);
	        	my $length = int($info->{SECS});
	        	$totlength += $length;
		}
	}
	$tothours = int($totlength / 3600);
	$totminutes = int(($totlength - ($tothours * 3600)) / 60);
	$totseconds = int($totlength % 60);
	$totlength = sprintf('%02d:%02d:%02d', $tothours, $totminutes, $totseconds);
	print "Total length of $file: $totlength\n";
}
