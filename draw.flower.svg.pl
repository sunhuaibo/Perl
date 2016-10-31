#!/usr/bin/perl -w
use strict;
use SVG;
@ARGV || die"usage: perl $0 <inlist> > out.svg\n";
my $inf = $ARGV[0];
my ($ndu,@array,%hash,%gr,@list,@groups,@uniq_group,%group_color, %sample_color);
my $svg = SVG->new('width',800,'height',650);
my $num=(split/\s+/,`wc -l $inf`)[0]- 1;

my $du=360/$num;
for (1..$num){
    $ndu=$du*($_ - 1);
    push @array,$ndu;
}

my @col=qw(crimson blue lightseagreen orange mediumpurple palegreen lightcoral dodgerblue lawngreen olive
    yellow fuchsia salmon mediumslateblue darkviolet purple sienna  black  tan chocolate skyblue turquoise cadetblue);
#my @colcut=@col[1..$num];
my %group_num;
my @samples;
for(`less $inf`){#只能用for
  #RS7     48      RSB     6       2
  #RS9     66      RSB     8       2
  #RS11    135     RSB     10      2
    chomp;
    my @fields = /\t/? split/\t/ : split;
    (@fields==2) && next;
    push @groups,$fields[2]; 
    push @samples, $fields[0]; #print by order  
    $group_num{$fields[2]} = $fields[4];
    $sample_color{$fields[0]} = $col[$fields[3]];
    $group_color{$fields[2]} = $col[$fields[4]];

}
@uniq_group = sort{ $group_num{$a} <=> $group_num{$b}} keys %group_num ;

my $eclipse_rx = 2*3.14*100/$num*0.6;
if($eclipse_rx<20){$eclipse_rx=20}elsif($eclipse_rx>60){$eclipse_rx=60}
my $eclipse_ry = 100;
my $fontsize = 15;


open IN, "$inf" || die "cant open it";
my $core = <IN>;
chomp $core;
my @core = split /\t/, $core;
while (my $line=<IN>){
    chomp $line;
    @list=split("\t",$line);
    my $jiao=shift (@array);
    my $group=$svg->group('transform',"rotate($jiao 330,300)");#圆心，角度
    my $ellip_fil;
    if(keys %group_color >1){
      $ellip_fil = $group_color{$list[2]}
    }else{
      $ellip_fil=$sample_color{$list[0]}
    }#group num ==1, fill by sample 
    $group->ellipse('cx',330,'cy',200,'rx',$eclipse_rx,'ry',$eclipse_ry,'fill',$ellip_fil,'fill-opacity','0.5'); 
    my $r = &rotate_text($jiao) + $jiao;
    $svg->text('x',&x($jiao),'y',&y($jiao),'text-anchor',&pos_text($jiao),'-cdata',$list[0],'font-family','Arial','font-size',$fontsize);
    $svg->text('x',&x2($jiao),'y',&y2($jiao),'text-anchor','middle','-cdata',&add_comm($list[1]),'font-family','Arial','font-size',$fontsize);
}

$svg->circle('cx',330,'cy',300,'r',35,'fill','white');
$svg->text('x',330,'y',300,'text-anchor','middle','-cdata',"$core[0]",'font-family','Arial','font-size',$fontsize);
$svg->text('x',330,'y',315,'text-anchor','middle','-cdata',&add_comm($core[1]),'font-family','Arial','font-size',$fontsize);

my $j = 0;

my $legend_width=20;
if(keys %group_color >1){#图裂部分：每个花瓣图中，组别>1时候，按照组别出图。否则按照样品出图
  for my $group1(reverse @uniq_group){
    my $legend_x = 650;#550;
    my $legend_y = 450-$legend_width*$j;
    $svg->rect('x',$legend_x,'y',$legend_y,'width',50 ,'height',$legend_width,'fill',$group_color{$group1},'stroke','black','fill-opacity','0.5');
    my $text_x=$legend_x+50+0.5*$fontsize;
    $svg->text('x',$text_x,'y',$legend_y+0.5*$legend_width+0.5*$fontsize,'text-anchor','start','-cdata',$group1,'font-family','Arial','font-size',$fontsize);
   $j++;
  }
}else{
  for my $sample(reverse @samples ){
    my $legend_x = 650; #550;
    my $legend_y = 450-$legend_width*$j;
    $svg->rect('x',$legend_x,'y',$legend_y,'width',50 ,'height',$legend_width,'fill',$sample_color{$sample},'stroke','black','fill-opacity','0.5');
    my $text_x=$legend_x+50+0.5*$fontsize;
    $svg->text('x',$text_x,'y',$legend_y+0.5*$legend_width+0.5*$fontsize,'text-anchor','start','-cdata',$sample,'font-family','Arial','font-size',$fontsize);
    $j++;   
  }
}



print $svg->xmlify;

#######

sub add_comm(){
    my $str = reverse $_[0];
    $str =~ s/(...)/$1,/g;
    $str =~ s/,$//;
    $_[0] = reverse $str;
}

sub leaf(){
   my $rx;
   if ($_[0] <= 9) {$rx = 40 - 3*($_[0] - 3);}
   else {$rx = 20;}
#   return $rx;

}
sub x (){
  my $x = 330 + 200*sin($_[0]*3.14159265/180);
}
sub y (){
my $y = 300 - 200*cos($_[0]*3.14159265/180);
if($_[0]>90 && $_[0]<270){$y+=15}
$y
}
sub x2 (){
  my $x = 330 + 140*sin($_[0]*3.14159265/180);
}
sub y2 (){
my $y = 300 - 140*cos($_[0]*3.14159265/180);

}

sub pos_text (){
  my $pos;
  if ($_[0] == 0 || $_[0] == 180 ){  
    $pos = "middle";
  }elsif(($_[0] > 0)&($_[0] < 180)){
    $pos = "start";
  }else{
    $pos = "end";
  }     
}

sub rotate_text(){
  my $ro;
  if (($_[0] >= 0) & ($_[0] < 180) ){
    $ro = 270;
  }else{
    $ro = 90; 
  }
}



