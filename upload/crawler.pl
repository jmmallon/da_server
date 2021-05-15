#!/usr/bin/perl

use MP3::Tag;
use MP3::Info;

$| = 1;
$ver = "5.0";

my $startTime = time;

$dirsfile = ($ARGV[0]) ? $ARGV[0] : "list.cfg";
$sqlfile = ($ARGV[1]) ? $ARGV[1] : "songlist.sql";
# $idtablename = "songlist_ids";
$tablename = "songlist";
my $insertline = "insert into $tablename (artist, song, album, track, filename, year, days, size, length, bitrate, station_id, id) values\n";

print "Crawler v. $ver using config file $dirsfile.\n";
print "Started: " . scalar(localtime($startTime)) . "\n";

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
if (@exclude) {
	$exclude = join('|', @exclude);
	$exclude =~ s/([\(\)\[\]\\\/\.\?\*])/\\$1/g;
	$exclude = '(' . $exclude . ')';
}

open(PLAYLIST,">playlist_library.txt") || die("playlist_library.txt - $!");

open(BAD,">badfile.txt") || die("badfile.txt - $!");
print BAD "These records have bad characters in them:\n\n";

open(FO,">$sqlfile") || die("$sqlfile - $!");
print FO << "ENDSQL";
use jmmallon;
DROP TABLE IF EXISTS $tablename;
CREATE TABLE $tablename (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    artist VARCHAR(255) NOT NULL,
    song VARCHAR(255) NOT NULL,
    album VARCHAR(255) NOT NULL,
    station_id INT(1) ZEROFILL,
    filename VARCHAR(255) NOT NULL,
    track INT(2) ZEROFILL,
    year INT(4) ZEROFILL,
    days INT(5) ZEROFILL,
    size INT(11) ZEROFILL,
    length INT(4) ZEROFILL,
    bitrate INT(3) ZEROFILL);
    $insertline
ENDSQL

open(LIST, ">library.txt") || die("Library - $!");
foreach $start (sort(@dirs)) {
   unless (-d $start and -r _) {
      print STDERR "Can't open directory $start in $dirsfile!\n";
      next;
   }
   &dirprobe($start, $exclude);
}
print FO "('1 - Voiceover Placeholder','','',0,'J:%%FTP%%Delicious Agony%%showdir%%vo1.mp3',0,10000,0,0,0,0,'12345');\n";

close(FO);
close(BAD);
# close(TEST);
close(LIST);

print "Created SQL file $sqlfile.\n";

print "Started: " . scalar(localtime($startTime)) . "\n";
print "Finished: " . scalar(localtime) . "\n";
my $elapsedTime = time - $startTime;
printf("Elapsed time: %02d:%02d:%02d\n", int( $elapsedTime / 3600 ), int( $elapsedTime % 3600 / 60 ), $elapsedTime % 60 );

sub dirprobe {
   my ($dir, $exclude, $count) = @_;
   my ($string) = "";
   print "$dir\n";
   opendir(DI, $dir) || die ("$dir - $!");
   my @list = sort(readdir(DI));
   closedir(DI);
   foreach my $file (@list) {
      my $filename = "$dir/$file";
      my $original_filename = $filename;
      my ($dev, $inode) = stat("$filename");
      next if ($file eq "." or $file eq ".." or -l $filename or ($exclude and $filename =~ /$exclude/i));
      if (-d $filename) {
         $count = &dirprobe($filename,$exclude,$count);
      } elsif ($file =~ /\.mp3$/i) {
         $album = $artist = $song = $length = $comment = $station_id_value = "";
         $size = $track = 0;
         @stuff = ();
	 $size = -s $filename;
         $info = get_mp3info($filename);
         $length = int($info->{SECS});
         $bitrate = int($info->{BITRATE});
         $bitrate =~ s/^0*//;
         undef $info;
         $mp3 = MP3::Tag->new($filename);
         @stuff = $mp3->autoinfo();
         if (@stuff) {
   	        $days = -M "$filename";
            $days = int($days);
	    # print LIST join('::', $length, $stuff[2], $filename, $stuff[5]) . "\n" if ($filename =~ m{Library} && $filename !~ m{Interviews});
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
	 	print "Sent to bad file: '$file'\n";
               print BAD "$artist - $song ($track - $album - $year) [$filename]\n";
            } else {
               print LIST join('::', $length, $artist, $original_filename, $year, $days) . "\n" if (($filename =~ m{Library} || $filename =~ m{Holiday}) && $filename !~ m{Interviews} && $filename !~ m{Promos});
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
	       if ($comment) {
               	     print PLAYLIST "$artist - $song ($track - $album - $year) - $comment - [$filename]\n";
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

               print FO qq#('$artist','$song','$album',$track,'$filename',$year,$days,$size,$length,$bitrate,$station_id_value,'$inode')#;

	       $count++;
	       if ($count % 30000 == 0) {
		       print FO ";\n$insertline";
	       } else {
		       print FO ",\n";
	       }
            }
         }
	else {
		print "Not handling '$file'\n";
	}
      }
   }
   return($count);
}
