$| = 1;
use Win32::GuiTest;
use LWP::UserAgent;

$WM_USER = 0x400;		# As defined in winuser.h
# $WM_COMMAND = 273;
$WM_COPYDATA = 74;
# $MAX_PATH = 260;		# As defined in windef.h

my $basedir = "J:\\ftp\\Delicious agony\\ShowPlaylists\\";
my $defaultdir = "J:\\ftp\\Delicious agony\\Default Stream\\Daily\\";
my $logfile = "$defaultdir" . "sched.log";
open (LOG, ">>$logfile") || die ("$!");
#
# -hourly, -daily, -twenty, -forty
my $MODE = $ARGV[0];
my $noadd = $ARGV[1];

chdir($defaultdir);
&get_handles;

my $now_string = localtime();
print LOG "Time: $now_string\n";
print LOG "Mode: $MODE\n";
my $daily = ($MODE eq "-daily");
my $hourly = ($MODE eq "-hourly");

my $current_idx = &GetPos;
my $idx = $current_idx + 1;
print LOG "Current position: $current_idx\n";
my $trackname = &GetTrackName($current_idx);
print LOG "Current song: $trackname\n";

my $filename = &GetNowFile($daily);

if (-f $filename) {
  print LOG "  Considering file $filename\n";

  # Get the time left first
  # $tl = &TimeLeft;
  # Put this after the end of the previous show
  $idx = $current_idx + 1;
  if ($noadd) {
    print LOG "  Would have inserted file $filename at position $idx\n";
  }
  else {
    print LOG "  Inserting file $filename at position $idx\n";
    &InsertPlaylistHere($filename, $idx, ($MODE eq "-hourly"));
  }
}
else {
  print LOG "No matching playlist files found\n";
}

print LOG "\n" . '=' x 40 . "\n\n";
close LOG;

sub get_handles {
  my @hndllist = &Win32::GuiTest::FindWindowLike(0, "Winamp", "1");
  $HWNDPARENT = $hndllist[0];
  $HWNDPE = &Win32::GuiTest::SendMessage($HWNDPARENT, $WM_USER, 1, 260);
}

sub GetTrackName {
  my $index = shift;
  my $name = &Win32::GuiTest::GetWindowText($HWNDPARENT);
  $name =~ m{[^ ]* (.*) - Winamp};
  return $1;
}

sub GetPos {
  my $position = &Win32::GuiTest::SendMessage ($HWNDPARENT, $WM_USER, 0, 125);
  return $position;
}

sub SetPos {
  my $index = shift;
  Win32::GuiTest::SendMessage ($HWNDPARENT, $WM_USER, $index, 121);
}

sub GetIndex {
  $rtn = &Win32::GuiTest::SendMessage ($HWNDPE, $WM_USER, 100, 0);
  return $rtn;
}

sub GetIndexTotal {
  $rtn = &Win32::GuiTest::SendMessage ($HWNDPE, $WM_USER, 101, 0);
  return $rtn;
}

sub AppendPlaylist {
  my $path = shift;
  my $struct = pack ("Z260", $path);
  my $structptr = unpack ("L", pack ("P", $struct));
  my $cds = pack ("LLL", 100, 260, $structptr);
  my $cdsptr = unpack ("L", pack ("P", $cds));

  &Win32::GuiTest::SendMessage ($HWNDPARENT, $WM_COPYDATA, 0, $cdsptr);
}

sub SaveEnd {
  my $index = shift;
  $rtn = &Win32::GuiTest::SendMessage ($HWNDPE, $WM_USER, 110, $index);
  return $rtn;
}

sub RestoreEnd {
  $rtn = &Win32::GuiTest::SendMessage ($HWNDPE, $WM_USER, 111, 0);
  return $rtn;
}

sub InsertFile {
  my $path = shift;
  my $index = shift;

  my $struct = pack ("Z260L", $path, $index);
  my $structptr = unpack ("L", pack ("P", $struct));
  my $cds = pack ("LLL", 106, 264, $structptr);
  my $cdsptr = unpack ("L", pack ("P", $cds));
  $rtn = &Win32::GuiTest::SendMessage ($HWNDPE, $WM_COPYDATA, 0, $cdsptr);
}

sub InsertNext {
  my $path = shift;
  my $t = &TimeTotal;
  $insertpos = &GetPos+1;
  # If the current track is an ident, wait till after the next song
  $insertpos++ if $t < 60;
  &InsertPlaylistHere ($path, $insertpos);
}

sub InsertPlaylistHere {
  my $path = shift;
  my $idx = shift;
  my $save_idx = shift;
  my $tot;

  &SaveEnd ($idx);
  &AppendPlaylist ($path);


  # Save the last index so shows don't overlap
  # and promos aren't played during shows.
  # But not for full playlists
  if ($save_idx) {
    my $t = &GetIndexTotal;
    $t--;
    open (IDX, ">sched.idx");
    print IDX "$t";
    close IDX;
  }

  &RestoreEnd;
}

sub TimeTotal {
  my $len = &Win32::GuiTest::SendMessage ($HWNDPARENT, $WM_USER, 1, 105);
  return $len;
}

sub TimeLeft {
  my $len = &TimeTotal;
  my $in = &Win32::GuiTest::SendMessage ($HWNDPARENT, $WM_USER, 0, 105);
  my $timeleft = $len - int($in/1000);
  return $timeleft;
}

sub GetNowFile {
  my $daily = shift;
  # my $content = get("http://www.unixtimestamp.com");
  # $content =~ m{<h3 class="text-danger">(\d+) <small>seconds since Jan 01 1970};
  # my $ua = LWP::UserAgent->new;
  # $ua->timeout(10);
  # $ua->env_proxy;
  # $ua->agent('Mozilla/5.0');
  # my $response = $ua->get("https://currentmillis.com");
  # my $content = $response->decoded_content;
  # print LOG "$content\n";
  # $content =~ m{<div id="ecclock">(\d+)<};
  # my $nowtime = $1;
  # print LOG "Time from web: $nowtime\n";
  # if (! $nowtime) {
  $nowtime = time;
	# }
  # $nowtime = time - 3600;
  print LOG "Original time: " . scalar(localtime($nowtime)) . "\n";
  $nowtime = $nowtime + 300;
  print LOG "Adjusted time: " . scalar(localtime($nowtime)) . "\n";
  my ($sec,$min,$hour,$mday,$mon,$year) = localtime($nowtime);
  # my ($sec,$min,$hour,$mday,$mon,$year) = localtime();
  my $today_file = sprintf ("%4d-%02d-%02d-%02d", $year + 1900, $mon + 1, $mday, $hour);

  print LOG "Searching for $today_file in $basedir\n";
  opendir DIR, $basedir;
  @filelist = grep {/^$today_file/} readdir DIR;
  closedir DIR;
  print LOG "@filelist\n";
  return $basedir.$filelist[0];
}
