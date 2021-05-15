use DateTime;
my $dtTue = DateTime->new( year => 2018, month => 1, day => 9, hour => '11' );
my $dtThu = DateTime->new( year => 2018, month => 1, day => 11, hour => '18' );

chomp(my @shows = <>);
foreach my $show (@shows) {
	my $tueFile = $dtTue->ymd . '-' . $dtTue->hour . '-GOMB.m3u';
	my $thuFile = $dtThu->ymd . '-' . $dtThu->hour . '-GOMB.m3u';
	foreach my $file ($tueFile, $thuFile) {
		open(my $fh, ">a/$file") || die ("$file - $!");
		print $fh "$show\n";
		close($fh);
	}
	print "$tueFile - $thuFile - $show\n";
	$dtTue->add( days => 7 );
	$dtThu->add( days => 7 );
}
