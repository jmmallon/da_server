#!/usr/bin/perl

# Finds updated and new files and generates the SQL and library entries for them

use File::Find;
use File::Basename;
use MP3::Tag;
use MP3::Info;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

$| = 1;
my $version = "6.0";

my $startTime = time;

# How many days back do we look? Argument or from start of library
my $limit = ($ARGV[0]) ? $ARGV[0] : 10000;

# Scan directory list
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
my $dirsfile = ($mon == 11 && $mday < 25) ? "list_holiday.cfg" : "list.cfg";
print "Using $dirsfile\n";

# File names
my $sqlfile = "songlist.sql";
my $libraryfile = "library.txt";
my $badfile = "badfile.txt";

# SQL info
my $tablename = "songlist";
my @sqlfields = ('artist', 'song', 'album', 'track', 'filename', 'year', 'date', 'size', 'length', 'bitrate', 'station_id', 'id');
my $insertline = "insert into $tablename (`" . join("`, `", @sqlfields) . "`) values\n";
my $duplicateline = " on duplicate key update\n" .  join(",\n", map { "`$_` = values(`$_`)" } @sqlfields) . ";\n";

# Initialize files - add VO entry if this is a full crawl
open(SQL,">$sqlfile") || die("$sqlfile - $!");
print SQL "use deliciou_suite;\n";
if (! $ARGV[0]) {
print SQL "DROP TABLE IF EXISTS $tablename;
CREATE TABLE $tablename (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    artist VARCHAR(255) NOT NULL,
    song VARCHAR(255) NOT NULL,
    album VARCHAR(255) NOT NULL,
    station_id INT(1) ZEROFILL,
    filename VARCHAR(255) NOT NULL,
    track INT(2) ZEROFILL,
    year INT(4) ZEROFILL,
    date varchar(25) NOT NULL,
    size INT(11) ZEROFILL,
    length INT(4) ZEROFILL,
    bitrate INT(3) ZEROFILL);
$insertline ('1 - Voiceover Placeholder','','',0,'J:%%FTP%%Delicious Agony%%showdir%%vo1.mp3',0,10000,0,0,0,0,'1') $duplicateline;\n";
}
close(SQL);

open(BAD,">$badfile") || die("$badfile - $!");
close(BAD);

if (! $ARGV[0]) {
	open(LIB,">$libraryfile") || die("$libraryfile - $!");
	close(LIB);
}

# Print startup info
print "Crawler v. $version using config file $dirsfile.\n";
print "Started: " . scalar(localtime($startTime)) . "\n";

# Load directories to be scanned
open(FI,"$dirsfile") || die("No config file $dirsfile - $!");
while ($dir = <FI>) {
	chomp($dir);
	if ($dir =~ /^!/) {
		$dir =~ s/^!//;
		push (@exclude, $dir);
	} else {
		push(@dirs, $dir);
	}
}
close(FI);

my $exclude;
# Create the exception regex
if (@exclude) {
	$exclude = join('|', @exclude);
	$exclude = '(' . $exclude . ')';
} else {
	# Bogus string used for exclusion if there are no excluded dirs
	$exclude = 'er' x 25;
}

my (@sqls, @librarys, @badlines);
my $max_track_time = 620;

# Scan each directory in the scan list
foreach $start (sort(@dirs)) {
   unless (-d $start and -r _) {
      print STDERR "Can't open directory $start in $dirsfile!\n";
      next;
   }

   # Use File::Find to traverse directories
   find({
	  # Check only non-excluded directories and MP3s changed since the limit
          'preprocess' => sub {
		              checkdir($limit, $exclude, @_);
		              },

	  # Get metadata from MP3s in SQL and library format, and collect badfile info
          'wanted' => sub {
			   my ($sql, $library, $badline) = &wanted;
			   push(@sqls, $sql) if ($sql);
			   push(@librarys, $library) if ($library);
			   push(@badlines, $badline) if ($badline);
			   if (scalar(@sqls) > 5000) {
				   linedump(\@sqls, \@librarys, \@badlines);
				   (@sqls, @librarys, @badlines) = ();
			   }
		          },

	  # Do not change directories
	  'no_chdir' => 1,
        }, $start);
}

# Output undumped lines
linedump(\@sqls, \@librarys, \@badlines);

# print join("\n", @lines) . "\n";

# Report results
print "Created SQL file $sqlfile.\n";

print "Started: " . scalar(localtime($startTime)) . "\n";
print "Finished: " . scalar(localtime) . "\n";
my $elapsedTime = time - $startTime;
printf("Elapsed time: %02d:%02d:%02d\n", int( $elapsedTime / 3600 ), int( $elapsedTime % 3600 / 60 ), $elapsedTime % 60 );

# Filter find input to narrow search
sub checkdir {
	my ($limit, $exclude, @entries) = @_;

	return(
		# Remove the directory name
		
		map { basename($_) }
			
		# Remove all but directories and mp3s updated since our limit

		grep(-d $_ || (/.mp3/ && lstat($_) && int(-M _) < $limit),
			
			# Remove excluded directories

			grep(!/$exclude/, 
			
				# Add directory name

				map { $File::Find::dir . '/' . "$_" }
			
					# Remove current and parent directories

					grep(!/^(\.|\.\.)$/, @entries)
			)
		)
	);
}

# Gather MP3 metadata from MP3 files
sub wanted {
   if (-f $File::Find::name) {

	 # print $File::Find::name . "\n"; return;

         my $filename = $File::Find::name;
         my $original_filename = $filename;
  
	 my ($sql, $library, $badline);
         my @stats = stat("$filename");
         my ($inode, $date) = @stats[1,9];
         $album = $artist = $song = $length = $comment = $station_id_value = "";
         $size = $track = 0;
         @stuff = ();
	 $size = -s $filename;
         $info = get_mp3info($filename);
         $length = int($info->{SECS});
         $bitrate = int($info->{BITRATE});
         $bitrate =~ s/^0*//;
         undef $info;
         $mp3 = MP3::Tag->new("$filename");
         @stuff = $mp3->autoinfo();
         if (@stuff) {
   	    $age = int((time() - $date) / (24 * 60 * 60)) + 1;
            map { s/^ *//; s/ *$//; s/'/`/g; s/\(/</g; s/\)/>/g; } @stuff;
            $filename =~ s/^ *//;
            $filename =~ s/ *$//;
            $filename =~ s/'/`/g;
            $filename =~ s/\(/</g;
            $filename =~ s/\)/>/g;
            $filename =~ s#[\\/]#%%#g;
            if ($filename =~ m{%%Library%%IDs%%}) {
               $station_id_value = 1;
            } else {
               $station_id_value = 0;
	    }
            ($song, $track, $artist, $album, $comment, $year) = @stuff[0..5];
            next if ($song =~ /voiceover/i or $song =~ /^voice\d+$/i or $song =~ /^vo\d+$/i or $song =~ /^don's voice/i or $artist =~ /^the canvas prog/i);
            $teststring = join('',$song, $track, $artist, $album, $year);
            if ($teststring =~ m{[^\x00-\x7F]} || $album =~ m{\s$} || $album =~ m{\s$} || $song =~ m{\s$} || $album =~ m{^\s} || $album =~ m{^\s} || $song =~ m{^\s}) {
	 	print "Sent to bad file: '$filename'\n";
               $badline = "$artist - $song ($track - $album - $year) [$filename]";
            } else {
               $library = join('::', $length, $artist, $original_filename, $year, $age) if (($filename =~ m{Library} || $filename =~ m{Holiday}) && $filename !~ m{Interviews} && $filename !~ m{Promos} && $length <= $max_track_time);
               unless ($album) {
                  if ($artist =~ / ?- /) {
                     $artist =~ / ?- (.*)$/;
                     $album = $1;
                     $artist =~ s/ ?- (.*)$//;
                  }
                  elsif ($artist =~ /from (the ([^ ]* )?album,? )?"([^"]*)/) {
                     $album = $3;
                  }
                  elsif ($song =~ /from (the ([^ ]* )?album,? )?"([^"]*)/) {
                     $album = $3;
                  }
                  elsif ($song =~ / ?- /) {
                     $song =~ / ?- (.*)$/;
                     $album = $1;
                     $song =~ s/ ?- (.*)$//;
                  } else {
                     $album = "";
                  }
               }
               $track =~ s#/\d+##;
	       $track =~ s#\D##g;
               $track = 0 unless ($track);
               $song = "None" unless ($song);
               $artist = "None" unless ($artist);
               $artist = "None" unless ($artist);
               $year = $1 if (not $year and $song =~ /,? from the (\d\d\d\d) /);
               $year =~ s/\D//g;
               $year = 0 unless ($year);
               $length = 0 unless ($length);
               $bitrate = 0 unless ($bitrate);

               $sql = qq#('$artist','$song','$album',$track,'$filename',$year,$date,$size,$length,$bitrate,$station_id_value,'$inode')#;
            }
         }
	 return($sql, $library, $badline);
   }
}

# Generate the SQL, Libary, and Bad files
sub linedump {
	my ($sql, $library, $bad) = @_;

	linedump_single($sql, $sqlfile, $insertline, $duplicateline, ',');
	linedump_single($library, $libraryfile);
	linedump_single($bad, $badfile);
}

# Add data to the requested file
sub linedump_single {
	my ($items, $file, $before, $after, $comma) = @_;

	if (@{$items}) {
		open(FO,">> $file") || die("$file - $!");
		print FO $before .  join("$comma\n", @{$items}) . $after;
		close(FO);
	}
}
