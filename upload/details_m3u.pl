#!/usr/bin/perl

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
use MP3::Tag;
use MP3::Info;

$| = 1;

$print_all = 1;

my $totlength;
foreach my $file (@ARGV) {
	$totlength += filecheck($file);
	print "Check of $file complete\n";
}

$tothours = int($totlength / 3600);
$totminutes = int(($totlength - ($tothours * 3600)) / 60);
$totseconds = int($totlength % 60);
$totlength = sprintf('%02d:%02d:%02d', $tothours, $totminutes, $totseconds);
print "Total length: $totlength\n";

sub filecheck {
	my ($file, $total) = @_;
	print "$file\n" if ($print_all);
	my $filename = $file;
	$file =~ s/\\/\\\\/g;
	$filename =~ s#\\#/#g;
	$filename =~ s#//#/#g;
	if ($filename =~ m{^[\\/]}) {
		$filename = "J:$filename";
	}
	unless (-e "$file") {
		print "$filename MISSING!!\n";
	}
	open(FI, "$file") || die ("$file - $!");
	my @files = <FI>;
	close(FI);
	if (! @files) {
		print "$file - EMPTY!\n";
	}
    	map { s/\r//g } @files;
 	foreach my $line (@files) {
		next if ($line =~ /^#/);
		chomp($line);
		$line =~ s/^\s*//g;
		$line =~ s/\s*$//g;
		next unless ($line);
		my $detail_line = $line;
		$line =~ s/\\/\\\\/g;
		if ($line =~ m{^[\\/]}) {
			$line = "J:$line";
		}
		unless (-e $line) {
			$line =~ s/\\+/\//g;
			print "$filename - $line MISSING!!\n";
			next;
		}
		if ($line =~ /.m3u$/) {
			$total += &filecheck($line, $total);
		}
		if ($line =~ /.mp3$/) {
			$total += details($detail_line),
		}
	}
	return($total);
}

sub details {
	my ($file) = @_;
	my ($line, $secs);
	if ($file =~ /\.mp3$/i) {
		my ($album, $artist, $song, $length);
		my $info = get_mp3info($file);
	       	$secs = int($info->{SECS});
         	$bitrate = int($info->{BITRATE});
		$length = sprintf('%02d:%02d', int($secs / 60), $secs % 60);
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
		# print "$length - $file - $track: $artist - $song ($album - $year) - $bitrate kbps - $length\n" if ($print_all);
		print "$length - $file\n" if ($print_all);
	}
	return($secs);
}
	
