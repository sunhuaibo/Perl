#!/usr/bin/perl -w
use strict;
@ARGV || die "Usage: perl $0 <infile.fna> > out.fna\n";
my $infna = shift;
(-f $infna) || die "$infna file is not exist\n";
my %dic_base = (R=>[A,G],Y=>[C,T],M=>[A,C],K=>[G,T],S=>[G,C],W=>[A,T],H=>[A,T,C],
	B=>[G,T,C],V=>[G,A,C],D=>[G,A,T]);
open IN,$infna or $!;


