$|=1;
use strict;
use warnings;
use LWP::Simple;
use MP3::Tag;
use MP3::Info;
use File::Basename;
$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

my $time = time;

my $url = 'http://canvasproductions.net/the-prog-hour';
my $file_location = "J:\\FTP\\Delicious Agony\\CPH";

# Unix date now minus that of first show, divided by 2 weeks' Unix time
my $shownum = int(($time - 877046400) / 1209600);
my $show = "CPH$shownum";

print "Doing Canvas Prog Hour $shownum\n";

# How close are we to Wed.?  Figure out & add to $time to get the correct date

my ($dayOfWeek) = (localtime($time))[6];

my $days_advance = 0;
if ($dayOfWeek < 3) {
	$days_advance = 3 - $dayOfWeek;
}
elsif ($dayOfWeek > 3) {
	$days_advance = 10 - $dayOfWeek;
}

my $wed_advance = $days_advance * 24 * 60 * 60;
my $sat_advance = ($days_advance + 3) * 24 * 60 * 60;
my $wed_advance2 = ($days_advance + 7) * 24 * 60 * 60;
my $sat_advance2 = ($days_advance + 10) * 24 * 60 * 60;

my ($wed_day, $wed_month, $wed_year) = (localtime($time + $wed_advance))[3..5];
my ($sat_day, $sat_month, $sat_year) = (localtime($time + $sat_advance))[3..5];
my ($wed_day2, $wed_month2, $wed_year2) = (localtime($time + $wed_advance2))[3..5];
my ($sat_day2, $sat_month2, $sat_year2) = (localtime($time + $sat_advance2))[3..5];

my $wednesday = sprintf('%04d-%02d-%02d', $wed_year + 1900, $wed_month + 1, $wed_day);
my $saturday = sprintf('%04d-%02d-%02d', $sat_year + 1900, $sat_month + 1, $sat_day);
my $wednesday2 = sprintf('%04d-%02d-%02d', $wed_year2 + 1900, $wed_month2 + 1, $wed_day2);
my $saturday2 = sprintf('%04d-%02d-%02d', $sat_year2 + 1900, $sat_month2 + 1, $sat_day2);

print "Dates: $wednesday, $saturday, $wednesday2, $saturday2\n";

# Make the show directory

chdir('/cygdrive/j/FTP/Delicious Agony/CPH');
print "Making $show directory\n";
mkdir("$show");
chdir("$show");

# Get the MP3 files

my @m3u1lines;
my @m3u2lines;
my $part;
my $ua = LWP::UserAgent->new;
$ua->timeout(10);

$ua->agent('Mozilla/5.0');
my $response = $ua->get($url);
if ($response->is_success) {
	my @html;
        (@html) = grep (m{button download}, split("\n", $response->decoded_content));

	foreach my $line (@html) {
		$line =~ m{href="([^"]*)"};
		my $trackURL = dirname($url) . $1;
		my $response = $ua->get($trackURL);
		my $html;
		if ($response->is_success) {
	        	($html) = grep (m{sitezoogle}, split("\n", $response->decoded_content));
		} else {
	        	die $response->status_line;
		}
		$html =~ m{href="([^\?]*)};
		my $file = "$1";
		my $local_file = basename($file);
		$local_file =~ m{part(\d)};
		$part = $1;
		my $title = "Canvas Prog Hour #${shownum} Part $part";
		print "Getting $local_file from $file - $title\n";
		my $res = getstore("$file", "$local_file");
		print "Result = $res\n" if ($res != 200);
		if (-e $local_file) {
			my $mp3_tag = MP3::Tag->new($local_file);
			$mp3_tag->get_tags();
			$mp3_tag->{'ID3v1'}->remove_tag if (exists($mp3_tag->{'ID3v1'}));
			$mp3_tag->{'ID3v2'}->remove_tag if (exists($mp3_tag->{'ID3v2'}));
			my $id3v1 = $mp3_tag->new_tag('ID3v1');
			my $id3v2 = $mp3_tag->new_tag('ID3v2');
			$id3v1->song($title);
			$id3v1->artist('Canvas Productions');
			$id3v1->write_tag();
			$id3v2->add_frame('TPE1', 'Canvas Productions');
			$id3v2->add_frame('TIT2', $title);
			$id3v2->write_tag();
		} else {
			print "Couldn't get $local_file at $file\n";
		}
		if ($local_file =~ m{part[12]}) {
			push(@m3u1lines, "$file_location\\$show\\$local_file\n");
		}
		if ($local_file =~ m{part[34]}) {
			push(@m3u2lines, "$file_location\\$show\\$local_file\n");
		}
	}

	print "Making playlists\n";
	print "Part 1\n";
	open(FI, ">${show}part1.m3u") || die ($!);
	print FI sort(@m3u1lines);
	print sort(@m3u1lines);
	close(FI);
	print "Part 2\n";
	open(FI, ">${show}part2.m3u") || die ($!);
	print FI sort(@m3u2lines);
	print sort(@m3u2lines);
	close(FI);

	chdir('/cygdrive/j/FTP/Delicious Agony/ShowPlaylists');
	my $playlist_line1 = "$file_location\\$show\\${show}part1.m3u\n";
	my $playlist_line2 = "$file_location\\$show\\${show}part2.m3u\n";
	my $wednesday_file = "${wednesday}-13-Canvas.m3u";
	my $saturday_file = "${saturday}-20-Canvas.m3u";
	open(FI, ">${wednesday_file}");
	print FI $playlist_line1;
	close(FI);
	open(FI, ">${saturday_file}");
	print FI $playlist_line1;
	close(FI);
	my $wednesday_file2 = "${wednesday2}-13-Canvas.m3u";
	my $saturday_file2 = "${saturday2}-20-Canvas.m3u";
	open(FI, ">${wednesday_file2}");
	print FI $playlist_line2;
	close(FI);
	open(FI, ">${saturday_file2}");
	print FI $playlist_line2;
	close(FI);

	foreach my $file ($wednesday_file, $saturday_file, $wednesday_file2, $saturday_file2) {
		&filecheck($file);
		print "Check of $file complete\n";
	}

} else {
        die $response->status_line;
}
sub filecheck {
	my ($file) = @_;
	my $filename = $file;
	$file =~ s/\\/\\\\/g;
	$filename =~ s#\\#/#g;
	$filename =~ s#//#/#g;
	unless (-e "$file") {
		print "$filename MISSING!!\n";
		return;
	}
	open(FI, "$file") || die ("$file - $!");
	my @files = <FI>;
	close(FI);
    	map { s/\r//g } @files;
 	foreach my $line (@files) {
		next if ($line =~ /^#/);
		chomp($line);
		$line =~ s/^\s*//g;
		$line =~ s/\s*$//g;
		next unless ($line);
		$line =~ s/\\/\\\\/g;
		unless (-e $line) {
			$line =~ s/\\+/\//g;
			print "$filename - $line MISSING!!\n";
			next;
		}
		if ($line =~ /.m3u$/) {
			&filecheck($line);
		}
	}
}
