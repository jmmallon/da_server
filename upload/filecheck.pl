foreach my $file (@ARGV) {
	filecheck($file);
	print "Check of $file complete\n";
}

sub filecheck {
	my ($file) = @_;
	my $filename = $file;
	$file =~ s/\\/\\\\/g;
	$filename =~ s#\\#/#g;
	$filename =~ s#//#/#g;
	if ($filename =~ m{^[\\/]}) {
		$filename = "J:$filename";
	}
	unless (-e "$file") {
		print "$filename MISSING!!\n";
	}
	open(FI, "$file") || die ("$file - $!");
	my @files = <FI>;
	close(FI);
	if (! @files) {
		print "$file - EMPTY!\n";
	}
    	map { s/\r//g } @files;
 	foreach my $line (@files) {
		next if ($line =~ /^#/);
		chomp($line);
		$line =~ s/^\s*//g;
		$line =~ s/\s*$//g;
		next unless ($line);
		$line =~ s/\\/\\\\/g;
		if ($line =~ m{^[\\/]}) {
			$line = "J:$line";
		}
		unless (-e $line) {
			$line =~ s/\\+/\//g;
			print "$filename - $line MISSING!!\n";
			next;
		}
		if ($line =~ /.m3u$/) {
			&filecheck($line, $result);
		}
	}
}
