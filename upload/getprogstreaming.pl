#!/usr/bin/perl

$| = 1;
use strict;
use LWP::UserAgent;
use File::Basename;
$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

my $year = (localtime(time))[5] + 1900;
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
 
my $maindir = dirname(dirname($ARGV[0]));
print "Doing $ARGV[0]\n\n";
my $response = $ua->get($ARGV[0]);
 
my $playlist;
if ($response->is_success) {
	my ($html) = grep (m{'playlistfile'}, split("\n", $response->decoded_content));
	$html =~ m{'playlistfile': '([^']*)'};
	$playlist = $1;
} else {
	die $response->status_line;
}

my @html;
my $getobject = ($playlist =~ m{http}) ? $playlist: "$maindir/$playlist";
print "Playlist: $getobject\n";
$response = $ua->get("$getobject");
if ($response->is_success) {
	@html = grep (m{media:content}, split("\n", $response->decoded_content));
} else {
	die $response->status_line;
}

$ua->show_progress(1);
my ($artist, $album, @tracks, $dirmade);
foreach my $line (@html) {
	$line =~ m{="([^"]*)};
	my $url = $1;
	my $dir = basename(dirname($url));
	my ($id, $artist, $album) = split(' - ', $dir, 3);
	$album = chars($album);
	$artist = chars($artist);
	if (! $dirmade) {
		$dirmade++;
		mkdir ($artist);
		chdir ("$artist");
		my $album = "$year - $album";
		mkdir ($album);
		chdir ("$album");
		print "Made $artist/$album\n";
	}
	my $track = basename($url);
	# $track =~ s{`}{\\`}g;
	$track = chars($track);
	$track =~ s{ }{ - };
	print "$track\n";
	$response = $ua->get("$url", ':content_file' => "$track") if ($track);
	if (! $response->is_success) {
		print "ERROR: " . $response->status_line . "\n";
	}
	print "\n";
}

sub chars {
	my ($string) = @_;
	$string =~ s{\\}{}g;
	$string =~ s{\s*/\s*}{--}g;
	$string =~ s{[\:\?]}{-}g;
	$string =~ s{`}{'}g;
	$string =~ s/([^\w\047'][a-z])/uc($1)/ge; 
	$string =~ s{Mp3}{mp3}g;
	$string = ucfirst($string);
	return($string);
}
