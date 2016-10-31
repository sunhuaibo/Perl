#!/usr/bin/perl -w
use strict;
@ARGV || die "usage: perl $0 <infile> <rowname_prefix>\n";
my ($in,$row_name) = @ARGV;
$row_name ||="OTU";
open IN,$in or die $!;
my $head = <IN>;
my @head = split /\s+/,$head;
$head[0] = "#" . $head[0];
push @head,"ID";
print "#\n",join("\t",@head),"\n";
my $i = 1;
my $out = "oldname_VS_newname.txt";
open OUT,">$out" or die $!;
while(<IN>){
	chomp;
	my @ll = split;
	push @ll,"ID";
	my $new_name = $row_name . $i;
	$ll[0] = $new_name;
	$i++;
	print OUT join("\t",$ll[0],$new_name),"\n";
	print join("\t",@ll),"\n";
}
close IN;
close OUT;
