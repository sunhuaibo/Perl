#!/usr/bin/perl -w
use strict;
@ARGV==2 || die"usage: perl Combine_table.pl <in.table> <in.group> > out.combine.table.xls\n";
for (@ARGV){
    (-s $_) || die$!;
}
my ($intable,$group) = @ARGV;
my %uniq_group;
my %sample_group;
my @group;
my $num = 0;
open IN,$group;
<IN>;
while(<IN>){
#for (`less $group`){
    chomp;
    my @l = split /\s+/;#sample group_anme
    $sample_group{$l[0]} = ($uniq_group{$l[1]}||=++$num);
}
close IN;
open IN,$intable || die$!;
chomp(my $head = <IN>);
my @head = ($head=~/\t/) ? split/\t/,$head : split/\s+/,$head;
for my $i(0 .. $#head){
    my $group_num;
    ($group_num = $sample_group{$head[$i]} || 0) && (push @{$group[$group_num-1]},$i);
}
my @group_name = sort {$uniq_group{$a}<=>$uniq_group{$b}} keys %uniq_group;
my @rank_num =split /\s+/, (`wc -l $group`);
my $sample_num = $rank_num[0] - 1;
if($sample_num==@head-2){
	print join("\t",$head[0],@group_name,$head[-1]),"\n";
	while(<IN>){
		chomp;
    	my @l = /\t/ ? split /\t/ : split;
    	my @out = map avg_sd(@l[@{$group[$_]}]), (0 .. $#group);
    	print join("\t",$l[0],@out,$l[-1]),"\n";
    }
}else{
    print join("\t",$head[0],@group_name),"\n";
    while(<IN>){
        chomp;
        my @l = /\t/ ? split /\t/ : split;
        my @out = map avg_sd(@l[@{$group[$_]}]), (0 .. $#group);
        print join("\t",$l[0],@out),"\n";
    }
}
close IN;
sub avg_sd{
    my ($avg,$sd);
    my $num = @_;
    for(@_){
        $avg += $_;
        $sd += $_**2;
    }
#    $avg /= $num;
##    my $i=$sd/$num - $avg**2;
#    warn "$sd\t$num\t$avg\n" if($i < 0);
#    warn "$sd\n" if($sd < 0 || $num <0 || $avg <0);
##    $sd = sprintf("%.6f",sqrt($sd/$num - $avg**2));
    $avg = sprintf("%.0f",$avg);
    return("$avg");  #return("$avg:$sd") ->return("$avg")
}

