srand;
my @lines = <>;
print shuffle(@lines);

sub shuffle {
	my @array = (@_);;
	my $i;
	for ($i = @array; --$i;) {
		my $j = int rand ($i+1);
		next if $i == $j;
 		@array[$i,$j] = @array[$j,$i];
	}
	return(@array);
}
