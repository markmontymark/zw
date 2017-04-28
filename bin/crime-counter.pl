#!perl

use strict;
use warnings;

my $first_split = '<p>Listed below are recent crimes in our immediate neighborhood to be aware of:</p>';
my $second_split = '<p>Information is from <a href="';
my $second_split_b = '<h3 id="important-info-from-the-san-diego-police-department">';

my($dir) = @ARGV;
my $data = &crimes($dir);
&report($data);

sub crimes{

	my($dir) = @_;

	my $retval = {};

	opendir D,$dir || die "Can't opendir $dir, $!\n";
	my( @files) = map { "$dir/$_" } (grep /\.html$/, grep !/^\./, readdir D);
	closedir D;
	#print "got ",join("\n",@files),"\n";

	for my $file (@files){
		open F,$file || die "Can't read file., $file, $!\n";
		my $content = join('',<F>);
		$content = (split($first_split,$content))[1];
		if(index($content,$second_split)>-1){
			$content = (split($second_split,$content))[0];
		}
		elsif(index($content,$second_split_b)>-1){
			$content = (split($second_split_b,$content))[0];
		}
		#print "$content\n\n###########\n\n";
		my(@crimenames) = $content =~ m/<p>([^<]+)<\/p>/isg;
		my(@dates) = $content =~ m/<li>([^<]+(?:am|pm))<\/li>/isg;
		#print "dates ",join('',@dates),"\n\n";
		my @rcrimenames;
		for my $crimename (@crimenames){
			$crimename = lc $crimename;
			$crimename =~ s/^\s+//;
			$crimename =~ s/\s+$//;
			$crimename =~ s/://g;
			next if index($crimename , 'nbsp') > -1;
			next if index($crimename , 'synopsis') > -1;
			next if index($crimename , 'the link below') > -1;
			next if index($crimename , 'there is a public park') > -1;
			push @rcrimenames,$crimename;
		}
		if( scalar(@dates) != scalar(@rcrimenames)){
			die "$file, different number of dates and crimes, dates are @dates, crimes are @rcrimenames";
		}

		my $len = scalar(@dates);

		for(my $i=0;$i<$len;$i++){
		  my $crimename = $rcrimenames[$i];
		  my $date      = $dates[$i];
			my($m,$d,$y)  = $date =~ m/(\d+)\/(\d+)\/(\d+)/;
			#print "$y $m $d\n";
			$m =~ s/^0//;
			$d =~ s/^0//;
			$retval->{"$y $m"}->{$crimename}++;
		}
	}
	return $retval;
}

sub report {
	my($data_per_month) = @_;
	for my $y_m (sort keys %$data_per_month){
		my $data = $data_per_month->{$y_m};
		print "$y_m\n";
		for my $crimename(sort {$data->{$b} <=> $data->{$a} } (keys %$data)){
			print $crimename ,' ',$data->{$crimename},"\n";
		}
		print "\n";
	}
}

