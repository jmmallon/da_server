$| = 1;
use Win32::GuiTest;
use File::Copy;

$WM_USER = 0x400;		# As defined in winuser.h
$WM_COMMAND = 273;
$WM_COPYDATA = 74;
$MAX_PATH = 260;		# As defined in windef.h

my $basedir = "C:\\Documents and Settings\\Joe\\Application Data\\Winamp\\";
my $destdir = "J:\\ftp\\Delicious agony\\ShowPlaylists\\";
my $defaultdir = "J:\\ftp\\Delicious agony\\Default Stream\\Daily\\";

my $basefile = "$basedir" . "winamp.m3u";
my $destfile = "$destdir" . "saved.m3u";
my $logfile = "$defaultdir" . "saved.log";

open (LOG, ">>$logfile") || die ("$!");

chdir($defaultdir);
&get_handles;

my $now_string = localtime();
print LOG "Time: $now_string\n";

my $current_idx = &GetPos;
my $idx = $current_idx + 1;
print LOG "Current position: $current_idx\n";
my $trackname = &GetTrackName($current_idx);
print LOG "Current song: $trackname\n";
print LOG "Writing playlist\n";
&WritePlaylist();

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

sub WritePlaylist {
  my $rtn = Win32::GuiTest::SendMessage ($HWNDPARENT, $WM_USER, 0, 120);
  copy($basefile, $destfile) || die("$!");
}

