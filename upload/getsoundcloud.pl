#!/usr/bin/perl

use LWP::UserAgent;
use JSON;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;
# my $clientID = '3a5fb5214d64c1f21fc652c83739ea3f';
my $clientID = 'LvWovRaJZlWCHql0bISuum8Bd2KX79mb';
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
 
my $userLink = $ARGV[0];
print "Doing $userLink\n";
$userLink =~ s{.*soundcloud.com/}{https://soundcloud.com/};
$userLink =~ s{\?.*}{};

my $soundURL = "https://api.soundcloud.com/resolve.json?url=$userLink&client_id=$clientID";
print "$soundURL\n";
my $response = $ua->get($soundURL);
 
my $jsonHash;
if ($response->is_success) {
     $result = decode_json($response->decoded_content);
} else {
     die $response->status_line;
}

my (@tracks, $artist, $title);
if (defined($result->{'tracks'})) {
	$title = $result->{'title'};
	foreach my $track (@{$result->{'tracks'}}) {
		push(@tracks, [ sprintf('%02d - %s.mp3', ++$count, $track->{'title'}), $track->{'stream_url'} . "?client_id=$clientID" ]);
		$artist = $track->{'user'}->{'username'};
	}
} else {
	push(@tracks, [ sprintf('%02d - %s.mp3', ++$count, $result->{'title'}), $result->{'stream_url'} . "?client_id=$clientID" ]);
	$artist = $result->{'user'}->{'username'};
}

$title = chars($title);
$artist = chars($artist);
if (!$artist) {
	$artist = "A";
}

mkdir("$artist");
chdir("$artist");
if ($title) {
	mkdir("$title");
	chdir("$title");
}

$ua->show_progress(1);
my $count = 0;
foreach my $item (@tracks) {
	$count++;
	next if ($ARGV[1] && ($count != $ARGV[1]));
	my ($track, $url) = @$item;
	print "Getting $track - $url\n";
	$track = chars($track);
	$response = $ua->get("$url", ':content_file' => "$track") if ($track);
	if (! $response->is_success) {
		print "ERROR: " . $response->status_line . "\n";
	}
	print "\n";
}
print "Done $artist - $title\n";

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
