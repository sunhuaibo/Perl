#!/usr/bin/perl -w

=head1 Name    

    Text_Processing_Tools.pl

=head1 Version

    Author  Huaibo Sun  sunhuaibo@novogene.com
    Version V1.0    2015-04-13

=head1 Usage

    perl Text_Processing_Tools.pl -i infile -o outfile --outdir ./ [-option]
    -i <infile>  input file name
    -o <outfile>    output file name
    --del <num> delete column
    --save <num>    save column
    --tran <verbose>    transfer file
    --mrow  print mean values as row (default: Keep 2 decimal)
    --mcol  print mean values as column (default: Keep 2 decimal)
    --srow  print sum values as row
    --scol  print sum values as column 

=cut

use strict;
use Getopt::Long;
my %opt=(outdir=>".");
GetOptions(\%opt,"outdir:s","i:s","o:s","del:s","save:s","tran","mrow","mcol","srow","scol");
($opt{i} || $opt{o} || @ARGV) || die `pod2text $0`;
#(-s $opt{i}) || die "Input file is empty\n";
my $in_file = $opt{i} ? $opt{i} : shift;
open IN,$in_file || die "$!";
$opt{o} && (open OUT,">$opt{o}" || die "$!");
if ($opt{del}){
    del_col(\*IN,\*OUT,$opt{del});
}
if ($opt{save}){
    save_col(\*IN,\*OUT,$opt{save});
}
if ($opt{tran}){
    transfer(\*IN,*OUT)
}
if($opt{mrow}){
    mean_sum(\*IN,\*OUT)
}
if($opt{mcol}){
    mean_sum(\*IN,\*OUT)
}
if($opt{srow}){
    mean_sum(\*IN,\*OUT)
}
if($opt{scol}){
    mean_sum(\*IN,\*OUT)
}
            
sub transfer{
    my ($file,$outfile)=@_;
    my @array;
    while(my $line = <$file>){
        chomp $line;
        my @l = $line=~/\t/? split /\t/,$line : split /\s+/,$line;
        for (0..$#l){
            push @{$array[$_]},$l[$_];
        }
    }
    for(0..$#array){
        $outfile ? (print $outfile join("\t",@{$array[$_]}),"\n") : (print join("\t",@{$array[$_]}),"\n");
    }
}
sub mean_sum{
    my ($file,$outfile,$method)=@_;
    my @matrix;
    chomp (my $head = <$file>);
    my @col_name = $head =~ /\t/ ? split /\t/,$head : split /\s+/,$head;
    shift @col_name;
    while(my $line = <$file>){
        ($line =~ /^#/) && next;
        chomp $line;
        my @array = $line =~ /\t/ ? split /\t/,$line : split /\s+/,$line;
        my $row_name = (shift @array);
        if($opt{mrow}){
            print $outfile "$row_name\t",avg(\@array),"\n";
        }
        if($opt{srow}){
            print $outfile "$row_name\t",avg(\@array),"\n";
        }
        for my $j (0..$#array){
            push @{$matrix[$j]},$array[$j];
        }
    }
    if($opt{mcol}||$opt{scol}){
        for my $l (0..$#matrix){
            print $outfile "$col_name[$l]\t",avg($matrix[$l]),"\n";
        }
    }    
}
sub avg{
    my ($l) = @_;
    my $num = @$l;
#    $num && die "Division can not be 0\n";
    my $sum;
    for(@$l){
        $sum += $_
    }
    if($opt{srow}||$opt{scol}){
        return $sum;
    }
    if($opt{mrow}||$opt{mcol}){
        my $avg = sprintf "%.2f",$sum/$num;
        return $avg;
    }
}
           
sub save_col{
    my ($file,$outfile,$save)=@_;
    my @save = split /,/,$save;
    while(my $line = <$file>){
        chomp $line;
        my @array = $line =~ /\t/ ? split /\t/,$line : split /\s+/,$line;
        my @save_col = @array[map {$_-1} @save];
        print $outfile join("\t",@save_col),"\n";
    }
}
sub del_col{
    my ($file,$outfile,$del)=@_;
    my @del = sort {$b<=>$a} split /,/,$del;
    while(my $line = <$file>){
        chomp $line;
        my @array = $line =~ /\t/ ? split /\t/,$line : split /\s+/,$line;
        my $num = @array;
        if($del[0]>$num){
            print " Error:Del column is out range\n";
            exit;
        }
        for(@del){
            splice(@array,$_-1,1);
        }
        print $outfile join("\t",@array),"\n";
    }
}
close IN;
close OUT;
