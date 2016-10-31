#!/bin/env perl
#================================================================
# Author: Sun Shuai                E-mail: sunshuai@geneplus.org.cn
# Last modified: 2016-10-19 09:59
# Filename: health_pass.pl
#================================================================
use strict;
use warnings;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use File::Basename qw(basename dirname);
use Getopt::Long;
use Data::Dumper;

my $usage = <<END;
 
 Usage: $0 -in <bed> -out <result>

END
die "$usage\n" if (@ARGV == 0);
my ($in,$out,$help);
GetOptions(
    'in=s'  => \$in,
    'out=s' => \$out,
) or die;
#my $genome = '/mnt/NL200/peizhh/protocol/Pipeline/NoahCare/db/hg19fa/hg19.fa';   
my $genome = '/mnt/NL200/peizhh/protocol/Pipeline/NoahCare/db/alignment/tgp_phase2_flat/hs37d5.fa';
my $tmpdir = dirname $out;

my %info;
my $total = 0;
`cp $in $out.chg.bed`;
`sed -i 's/chr//' $out.chg.bed`;
my @bam = glob("/mnt/NL200/peizhh/LiverC/SJTU_HuangJian/ReAnalysis/Forth_Arrangement/0_baseline/*bam");
foreach my $file (@bam){
    `/mnt/NL200/sunshuai/pipeline/checkVariation/pysnv.py --ref $genome --bam $file --bed $out.chg.bed --outdir $tmpdir > $out.tmp.bed 2>/dev/null`;
    open FL,"$out.tmp.bed";
    while (<FL>){
        chomp;
        my @tmp = split;
        next if ($tmp[1]=~/\D/ or $tmp[2]=~/\D/);
        
        my $lable = "$tmp[0]\t$tmp[1]\t$tmp[2]\t$tmp[3]\t$tmp[4]";
        
        if (!exists $info{$lable}){
            $info{$lable}[0] = 0;    
            $info{$lable}[1] = 0;    
        };

        if ($tmp[5]>=40){
            if ($tmp[6]>=20 and $tmp[9] >= 20){
                $info{$lable}[0] += 0.5;
                #$poly += 0.5;
            }elsif($tmp[9]>=40){
                $info{$lable}[0] += 1;
                #$ploy += 1;
            }
        };
        if ($tmp[5]>=40){
            if ( $tmp[9] >= 5 and $tmp[9] < 20){
                $info{$lable}[1] += 1;
                #$sys += 1;
            }
        };
    };
    `rm -r $tmpdir/buf_reads/`;
    `rm $out.tmp.bed`;
    $total+=1;
};
`rm $out.chg.bed`;

open FLS,">$out";
foreach (sort keys %info){
    print FLS "$_\t$total\t$info{$_}[0]\t$info{$_}[1]\n";
};
close FLS;
