srand;

# Number of seconds between songs by the same artist

my $dir = "J:\\FTP\\Delicious Agony\\Library";
my $holiday_dir = "J:\\FTP\\Delicious Agony\\Holiday Music";
# my $playlist_dir = "/tmp";
my $playlist_dir = "J:\\FTP\\Delicious Agony\\ShowPlaylists";
my $library_dir = "J:\\lists";
my $print_dir = $dir;
$print_dir =~ s{^..}{};
my $artist_repeat_standard = 12600 * 2;
my $max_track_time = 620;
my $block_time = 1440;
my $days = $ARGV[0];
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $holiday = ($mon == 11 && $mday < 25) ? 1 : 0;
my $seconds_per_day = 24 * 3600;
if (! $days) {
	print "Must provide number of days!\n";
	exit;
}
my $startday = $ARGV[1] * $seconds_per_day;

my %artist_repeats = (
	'Camel' => 9600,
	'Dream Theater' => 12600,
	'Eloy' => 12600,
	'Focus' => 12600,
	'Genesis' => 9600,
	'IQ' => 12600,
	'Jethro Tull' => 12600,
	'Kansas' => 12600,
	'King Crimson' => 9600,
	'Marillion' => 9600,
	'Pink Floyd' => 9600,
	'Premiata Forneria Marconi' => 12600,
	'Rush' => 9600,
	'Strawbs' => 9600,
	'Trans-Siberian Orchestra' => 9600,
	'The Moody Blues' => 12600,
	'Uriah Heep' => 12600,
	'Yes' => 9600,
);

my @day_show_hours = (
	6,
	10,
	12,
	11,
	9,
	6,
	3
);

opendir(DI, "$dir/Promos");
my @items = readdir(DI);
closedir(DI);
opendir(DI, "$holiday_dir/Promos");
my @holiday_promos = grep { m{.mp3$} } readdir(DI);
closedir(DI);
map { s{^}{$holiday_dir/Promos/} } @holiday_promos;
my @promos = grep { m{.mp3$} } @items;

# Use for Yes marathon promos
# @special_promos = grep { m{arathonA} } @promos;

# @special_promos = grep { m{YesMarathonAd} } @promos;
# ($spectrum) = grep { m{RosF}i } @promos;
# push(@special_promos, $spectrum);
@promos = grep { ! m{UnCanc} } @promos;
@promos = grep { ! m{arathon} } @promos;
@promos = grep { ! m{sexy} } @promos;
map { s{^}{$print_dir/Promos/} } @promos, @special_promos;
my $number_of_promos = @promos;
my $number_of_special_promos = @special_promos;

# Special promo rate - loopcount remainder from 8 - set to 9 if no special promos

my $special_promo_rate = 9;

# print "$number_of_promos Promos\n";

my %ids;

open(FI, "$dir/IDs/idents.ini") || die($!);
my $band;
while (my $line = <FI>) {
	$line =~ s{\x0D}{}g;
	chomp($line);
	next unless ($line);
	if ($line =~ m{^\[([^\]]*)}) {
		$band = $1;
		next;
	}
	push(@{$ids{$band}}, "$print_dir/IDs/$line");
}

my @tracks;
my @holiday_tracks;
open("FI", "$library_dir/library.txt") || die($!);
while (my $line = <FI>) {
	chomp($line);
	my ($time, $artist, $file, $year) = split(q{::}, $line);
	if ($time <= $max_track_time) {
		if ($file =~ m{Holiday Music}) {
			push(@holiday_tracks, { 'time' => $time, 'file' => $file, 'artist' => $artist, 'year' => $year });
		} else {
			push(@tracks, { 'time' => $time, 'file' => $file, 'artist' => $artist, 'year' => $year });
		}
	}
}
close(FI);

print "Holiday: $holiday\n";

my $count;
my $special_promo = 0;
my %last_played;
my %used_tracks;
my %used_holiday_tracks;
my $number_of_tracks = @tracks;
my $number_of_holiday_tracks = @holiday_tracks;
my $nowtime = time + $startday;

for (my $i = 0; $i < $days; $i++) {
my %last_played;
	my $loopcount = 0;
	$nowtime += $seconds_per_day;
	my ($mday,$mon,$year,$wday) = (localtime($nowtime))[3,4,5,6];
	my $playlist_filename = sprintf('%04d-%02d-%02d-01-Daily.m3u', $year + 1900, $mon + 1, $mday);
	print "Doing $playlist_filename\n";
	open(FO, ">$playlist_dir/$playlist_filename");
	# open(FO, ">$playlist_dir/new_playlist-$i.m3u");
	my $loop_time = my $total_time = 0;
	my %used_promos;

	my $day_time = $seconds_per_day - (($day_show_hours[$wday] - 1) * 3600);
	while ($total_time < $day_time) {
		my ($track, $track_number);
		if ($count % 15 || ! $holiday) {
			$track_number = int(rand($number_of_tracks));
			next if ($used_tracks{$track_number});
			$track = $tracks[$track_number];
		} else {
			$track_number = int(rand($number_of_holiday_tracks));
			next if ($used_holiday_tracks{$track_number});
			$track = $holiday_tracks[$track_number];
		}

		my $track_time = $track->{'time'};
		next unless ($track_time > 135 && $track_time < $max_track_time);
		my $track_file = $track->{'file'};
		my $track_artist = $track->{'artist'};
		my $loop_and_track = $loop_time + $track_time;
	        my $artist_time = $total_time - $last_played{$track_artist};
	        # if (! $artist_time) { $artist_time = 2; }
		my $artist_repeat = (defined($artist_repeats{$track_artist})) ? 
			$artist_repeats{$track_artist} : $artist_repeat_standard;
		if ($loop_and_track < $block_time) {
			next if ($track_file !~ m{Holiday Music} && ($artist_time < $artist_repeat) && ($last_played{$track_artist} != 0));
			if ($loop_time == 0) {
				my $item;
				if (defined($ids{$track_artist}) && ($loopcount % 5 != 0)) {
					my @id_array = @{$ids{$track_artist}};
					my $id_number = int(rand(scalar(@id_array)));
					$item = $id_array[$id_number];
				} else {
					if ($loopcount % $special_promo_rate == 0) {
						if ($special_promo == 1) {
							$special_promo = 0;
						} else {
							$special_promo = 1;
						}
						# $special_promo = int(rand($number_of_special_promos));
						$item = $special_promos[$special_promo];
					} elsif (@holiday_promos && $loopcount % 8 == 9) {
						$item = $holiday_promos[$holiday_promo];
						$holiday_promo = ($holiday_promo < $#holiday_promos) ? $holiday_promo + 1  : 0;
					} else {
						my $promo;
						do {
							$promo = int(rand($number_of_promos));
							$item = $promos[$promo];
						} while (defined($used_promos{$promo}));
						$used_promos{$promo}++;
						%used_promos = () if (scalar(keys(%used_promos)) == $number_of_promos);
					}
				}
				print FO "\n" . $item . "\n";
			}
			$used_tracks{$track_number}++;
			print FO "$track_file\n";
			$total_time += $track_time;
			$last_played{$track_artist} = $total_time;
			$loop_time += $track_time;
			if ($loop_time > 1200) {
				$loop_time = 0;
				$loopcount++;
			}
			$count++;
		}
	}
	close(FO);
	my $tothours = int($total_time / 3600);
	my $totminutes = int(($total_time - ($tothours * 3600)) / 60);
	my $totseconds = int($total_time % 60);
	my $totlength = sprintf('%02d:%02d:%02d', $tothours, $totminutes, $totseconds);
	print "Playlist time: $totlength\n=============================\n";
}

