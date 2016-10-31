#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use Cwd qw(abs_path);
use Getopt::Long;
@ARGV>=2 || die "Usage:
	perl $0 <OTU.table> <venn.list> --outdir --group_list
	--group.list: 	samplename\tgroupname if this is set,then samples in same group will be the same colour;
					if not seted then samples will be pained in uniq colour
	--outdir 		default .
\n";

my($otu_table, $venn_list ) = @ARGV;
my $outdir = ".";
my $group_list;
GetOptions("outdir:s"=>\$outdir,"group_list:s"=>\$group_list);
for($otu_table, $venn_list,$outdir){$_=abs_path($_)}
$group_list && ($group_list=abs_path($group_list) );

# use lib "$Bin/../../00.Commbin/";
# use PATHWAY;
# ( -s "$Bin/../../../bin/Pathway_cfg.txt" ) || die "error: can't find config at $Bin/../../../bin, $!\n";
# my ( $R, $svg2xx ) = get_pathway( "$Bin/../../../bin/Pathway_cfg.txt", [qw(R2 SVG2XX)] );
(-s $outdir) || mkdir($outdir);
open OTU,"<$otu_table" or die$!;
<OTU>;#去掉第一行
my $head=<OTU>;
my @sample_names = ($head=~/\t/) ? (split/\t/,$head) : (split/\s+/,$head);
pop @sample_names;

my %sample_order=map{($sample_names[$_],$_)} 1..$#sample_names;
my %order_sample_uniq;
my @common;
my (%sample_group, %sample_num, %group_num);
my $num=0;
my $i=0;
if( $group_list &&(-s $group_list)){#样品韦恩图情况。s1->g1,颜色
    for(`less $group_list`){
        chomp;
        my @fileds = split;
        $sample_group{$fileds[0]} = $fileds[1];
        $sample_num{$fileds[0]} = $i++;
        $group_num{$fileds[1]} ||= $num++;
    }
}
else{
    %sample_group = map{($sample_names[$_],$sample_names[$_])} 1..$#sample_names;
}
open VENN,"<$venn_list"  or die$!;
my @venn_pic_num;
while(<VENN>){
	chomp;
	my @files= /\t/ ? split/\t/ : split/\s+/;
	push @venn_pic_num,[@files];#
}
close VENN;

my @common_num;
my %outfile_names;
my %order_sample_uniqOTU;
my %order_sample_commonOTU;
while (my $otu_line=<OTU>){
	chomp $otu_line;
	my @otu_lines = ($otu_line=~/\t/) ? split/\t/,$otu_line : split/\s+/,$otu_line;
	my $j=0;
	for my $i(0..$#venn_pic_num){
		$j++;
		my @one_venn_samples = @{$venn_pic_num[$i]};
		my $sample = is_uniq(\@one_venn_samples, \@otu_lines, \%sample_order);
		$outfile_names{$j}=join("_",$j,@one_venn_samples);
		if($sample eq "common_otu"){
			$common_num[$i]++;
			$order_sample_commonOTU{$j}.="$otu_lines[0]\t$otu_lines[-1]\n";
		}elsif($sample){
			$order_sample_uniq{$j}{$sample}++; #uniq out count
			$order_sample_uniqOTU{$j}{$sample}.="$otu_lines[0]\t$otu_lines[-1]\n";
		}		
	}
}
(-d "$outdir/flowerdata") || mkdir("$outdir/flowerdata");
for my $order(keys %order_sample_uniq){#change 
	my $outfile=$outfile_names{$order};
    my @samples = split/\_/,$outfile;
    shift @samples;
	open OUT, ">$outdir/$outfile.xls" or die $!;

	print OUT "core\t$common_num[$order-1]\n";
    my $i =0;
    for my $sample(@samples){
        $i++;
    #for my $sample(keys %{$order_sample
		open UNITAX,">$outdir/flowerdata/$order.$sample.uniq.otu.xls" or die $!;

        $order_sample_uniq{$order}{$sample} ||= 0;
        $group_num{$sample_group{$sample}} ? 
		print OUT "$sample\t$order_sample_uniq{$order}{$sample}\t$sample_group{$sample}\t$i\t$group_num{$sample_group{$sample}}\n" : 
        print OUT "$sample\t$order_sample_uniq{$order}{$sample}\t$sample_group{$sample}\t$i\t$i\n";
		$order_sample_uniqOTU{$order}{$sample} ? ( print UNITAX "$order_sample_uniqOTU{$order}{$sample}") : (print UNITAX "no uniqtax");
		close UNITAX;
	}
	close OUT;	
	open COMMON,">$outdir/flowerdata/$outfile.common.otu.xls" or die $!;
	print COMMON "$order_sample_commonOTU{$order}";
	close COMMON;
	system("perl $Bin/draw.flower.svg.pl $outdir/$outfile.xls > $outdir/$outfile.flower.svg ");
#	system("/PROJ/MICRO/share/16S_pipeline/16S_pipeline_V1.09.1/software/svg2xxx_release/svg2xxx -t png $outdir/$outfile.flower.svg");
}
# system "perl $Bin/combine_fig.pl ./ -sufix flower.png -hd 0.02 > flower_display.svg";
# system "$svg2xx -t pdf flower_display.svg";   
# system "$svg2xx -t png -dpi 200 flower_display.svg"; 

close OTU;

########################sub function ###################
sub is_uniq{
	my($venn_samples, $otu_lines, $sample_order) = @_;
	my %order_sample;
	for my $sample(keys %{$sample_order}){
		$order_sample{ ${$sample_order}{$sample} } = $sample;
	}
	my $no_zero_num=0;
	my ($index,$sample_total_num) ;
	for my $sample(@{$venn_samples}){
		$sample_total_num++;
		my $i=${$sample_order}{$sample};
		if(${$otu_lines}[$i] != 0){			
			$no_zero_num ++;
			$index = $i;
		}
	}
	if($no_zero_num==1){
		return $order_sample{$index};
	}elsif($no_zero_num==@{$venn_samples}){
		return "common_otu";
	}else{
		return 0;
	}

}
__END__
#输出文件，第四列是样品编号，第五列是组编号，在绘图的时候添加判断，如果样品属于同一个组，则按照样品的编号绘制颜色

