#!/usr/bin/env perl -w
use strict;
use Getopt::Std;
use ManufParser;
use ManufTreeBuilder;
use Term::ANSIColor 2.00 qw(:pushpop);
use Data::Dumper;

die "wrong # args, try $0 filename" unless (1 == @ARGV);
my $filename = $ARGV[0];

print STDERR PUSHCOLOR BRIGHT_GREEN "Loading $filename\n";

open(my $fh, "<$filename") or die "Cannot open $filename: $!";
my $parser = new ManufParser($fh);
my @records = $parser->parse();

print STDERR PUSHCOLOR BRIGHT_GREEN "loaded ", scalar(@records), " records\n";

my $treeBuilder = new ManufTreeBuilder();
foreach my $record (@records) {
	$treeBuilder->insert($record);
}



print new Data::Dumper([$treeBuilder->root()], ["tree"])->Sortkeys(1)->Dump;


