#!/usr/bin/perl

use MP3::Tag;
use MP3::Info;

$| = 1;

	opendir(DI, ".") || die (". - $!");
	@list = sort(readdir(DI));
	closedir(DI);
	foreach $file (@list) {
		if ($file =~ /\.mp3$/i) {
			my ($album, $artist, $song, $length);
			my $info = get_mp3info($file);
	        	$length = int($info->{SECS});
	        	$totlength += $length;
         		$bitrate = int($info->{BITRATE});
			$length = sprintf('%02d:%02d', int($length / 60), $length % 60);
			undef $info;
			my $mp3 = MP3::Tag->new($file);
			$mp3->get_tags();
			if (exists $mp3->{ID3v2}) {
				$v2 = $mp3->{ID3v2};
				($album) = $v2->get_frame("TALB");
				($song) = $v2->get_frame("TIT2");
				($artist) = $v2->get_frame("TPE1");
				($track) = $v2->get_frame("TRCK");
				($year) = $v2->get_frame("TYER");
				$album = "None" unless ($album);
				$song = "None" unless ($song);
				$artist = "None" unless ($artist);
				$length = 0 unless ($length);
			}
			print "$file - $track: $artist - $song ($album - $year) - $bitrate kbps - $length\n";
		}
	}
	$tothours = int($totlength / 3600);
	$totminutes = int(($totlength - ($tothours * 3600)) / 60);
	$totseconds = int($totlength % 60);
	$totlength = sprintf('%02d:%02d:%02d', $tothours, $totminutes, $totseconds);
print "Total length: $totlength\n";
