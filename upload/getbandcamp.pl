#!/usr/bin/perl
$| = 1;
use LWP::UserAgent;
use HTML::Entities;
use JSON;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

my $ua = LWP::UserAgent->new;
$ua->timeout(30);
 
foreach my $arg (@ARGV) {
	print "Doing $arg\n";
	my $response;
	do {
		$response = $ua->get($arg);
	} while (! $response->is_success);
	 
	# my @html;
	if ($response->is_success) {
		# @html = split("\n", $response->decoded_content);
	     $response->decoded_content =~ m{data-tralbum="([^"]*)"}si;
             $json = decode_entities($1);
	} else {
	     die $response->status_line;
	}
	
	my ($artist, $album, $date, $captureLines, $jsonHash, @tracks);
	# foreach my $line (@html) {
	# if ($line =~ m{artist\s*: "([^"]*)}) {
			# }
			# elsif ($line =~ m{album_title\s*: "([^"]*)}) {
			# }
			# elsif ($line =~ m{trackinfo\s*:\s(.*),$}) {
			# $json = $1;
			# }
			# if ($line =~ m{album_release_date: ".. ...
			# }
			# }
	$json =~ s{[^\032-\177]}{%}g;
	eval {
		$jsonHash = decode_json($json);
	};

	$artist = chars(lc($jsonHash->{'artist'}));
	$album = chars(lc($jsonHash->{'current'}->{'title'}));
	$jsonHash->{'album_release_date'} =~ m{(\d{4})};
	$date = $1;
	print "Done $artist - $album ($date)\n";

	foreach my $track (@{$jsonHash->{'trackinfo'}}) {
		push(@tracks, [ sprintf('%02d - %s.mp3', $track->{'track_num'}, $track->{'title'}), $track->{'file'}->{'mp3-128'} ]);
	}
	# print Dumper($jsonHash) . "\n";
	if (!$album) { $album = "Tracks"; }
	if (!$date) { $date = "Tracks"; }
	my $albumdir = "$artist/$date - $album";
	mkdir("$artist");
	mkdir("$albumdir");
	chdir("$albumdir");
	
	$ua->show_progress(1);
	my $count = 0;
	foreach my $item (@tracks) {
		$count++;
		my ($track, $url) = @$item;
		$url = "http:$url" if ($url !~ m{http});
	print "$url\n";
		print "Getting $track\n";
		$track = chars($track);
		do {
			$response = $ua->get($url, ':content_file' => "$track") if ($track);
		} while (! $response->is_success);
		if (! $response->is_success) {
			print "ERROR: " . $response->status_line . "\n";
		}
		print "\n";
	}
	print "Done $artist - $album ($date)\n";
	chdir("../..");
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
