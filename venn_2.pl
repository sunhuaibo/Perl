#!/usr/bin/perl
use strict;
use FindBin qw($Bin);
use warnings;
@ARGV || die "usage: perl $0 <otu_table.txt> <venn_list>\n";
open IN, $ARGV[0];
<IN>;

#use lib "$Bin/../../00.Commbin/";
#use PATHWAY;
#( -s "$Bin/../../../bin/Pathway_cfg.txt" ) || die "error: can't find config at $Bin/../../../bin, $!\n";
#my ( $R, $svg2xx ) = get_pathway( "$Bin/../../../bin/Pathway_cfg.txt", [qw(R2 SVG2XX)] );
my $R = "/mnt/NL200/xiongdk/software/R-3.2.3/bin/Rscript";

my $title      = <IN>;
my @title      = split /\t/, $title;
my $sample_num = @title - 2;
my ( $i, @line, $otu, %list, %list2, %taxon, %num );

while (<IN>) {
	chomp;
	@line = split /\t/, $_;
	$otu = $line[0];
	for ( $i = 1 ; $i <= $sample_num ; $i++ ) {
		if ( $line[$i] ne "0.0"&&($line[$i] != 0) ) {
			$list{ $title[$i] } .= "\"" . $otu . "\",";
			$list2{$otu}{ $title[$i] } = 0;
			$taxon{$otu} = $line[ $sample_num + 1 ];
			$num{ $title[$i] }++;
		}
	}
}
close IN;

my ( @sample, $list, $filename, $number, %hash, $j );
open IN, $ARGV[1];
my $first_venn;
my @venngraphs;
open OUT, ">venn.R";
print OUT "library(VennDiagram)
library(RColorBrewer)
fivecol<-c('cornflowerblue', 'green', 'maroon', 'darkorchid1','orange')
";

foreach my $key ( keys %list ) {
	substr( $list{$key}, -1, 1 ) = "";
}
while (<IN>) {
	$j++;
	chomp;
	@sample = split /\s+/, $_;
	$number = @sample;
	next if !$number;
	foreach my $key1 ( keys %list2 ) {
        my $key=$j;
		for ( my $i = 0 ; $i <= $#sample ; $i++ ) {
			if ( exists $list2{$key1}{ $sample[$i] } ) {
                $key.="_$sample[$i]";
			}
        }
        $hash{$key}.="$key1\t$taxon{$key1}\n";
    }

	foreach my $key2 (@sample) {
		if ( exists $list{$key2} ) {
			$list .="\'$key2\'"."=c(".$list{$key2} ."),";
			$filename .= $key2 . "_";
		}
	}
	substr( $list,     -1, 1 ) = "";
	substr( $filename, -1, 1 ) = "";
	if($number==5){
		print OUT "
venn<-venn.diagram(list($list),filename=NULL,margin=0.1,cat.fontface='bold',cex = c(1.5, 1.5, 1.5, 1.5, 1.5, 1, 0.8, 1, 0.8, 1, 0.8, 1, 0.8, 1, 0.8, 1, 0.55, 1, 0.55, 1, 0.55, 1, 0.55, 1, 0.55, 1, 1, 1, 1, 1, 1.5),col = 'white',alpha = 0.50,lwd =1.2,fill=fivecol[1:$number],fontfamily = 'Times',cat.col =fivecol[1:$number])
pdf(\"$j" . "_" . $filename . "venn.pdf\")
grid.draw(venn)
dev.off()\n";
	}else{
		print OUT "
venn<-venn.diagram(list($list),filename=NULL,margin=0.1,cat.fontface='bold',cex = 1.1,col = 'white',alpha = 0.50,lwd =1.2,fill=fivecol[1:$number],fontfamily = 'Times',cat.col =fivecol[1:$number])
pdf(\"$j" . "_" . $filename . "venn.pdf\")
grid.draw(venn)
dev.off()\n";
	}
	push( @venngraphs, "$j\_$filename" . "venn.pdf" );
	$list     = "";
	$filename = "";
}
close IN;
close OUT;

`$R -f venn.R`;

# foreach my $pdf (@venngraphs) {
# 	my $png = $pdf;
# 	$png =~ s/pdf$/png/i;
# 	system("/usr/bin/convert -density 120 $pdf $png ");
# }

#system "perl $Bin/combine_fig.pl ./ -sufix venn.png -hd 0.02 > venn_display.svg";
#system "$svg2xx -t pdf venn_display.svg";
#system "$svg2xx -t png venn_display.svg";
( -d "venndata" ) || mkdir "venndata";
foreach my $key ( keys %hash ) {
	next if ($key eq "1" || $key eq "2" || $key eq "3" || $key eq "4" || $key eq "5");
    open OUT, ">venndata/$key.vennarea.xls" || die $!;

    print OUT $hash{$key};
	close OUT;
}
