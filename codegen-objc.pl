#!/usr/bin/env perl -w
use strict;
use Getopt::Std;
use ManufParser;
use Term::ANSIColor 2.00 qw(:pushpop);

sub toCArrayLiteral {
	my (@integers) = @_;
	return sprintf("(unsigned char[]){%s}", join(", ", map({"0x" . $_} @integers)));
}

sub quote {
	return "\"$_[0]\"";
}

die "wrong # args, try $0 filename" unless (1 == @ARGV);
my $filename = $ARGV[0];

print STDERR PUSHCOLOR BRIGHT_GREEN "Loading $filename\n";

open(my $fh, "<$filename") or die "Cannot open $filename: $!";
my $parser = new ManufParser($fh);
my @records = $parser->parse();

print STDERR PUSHCOLOR BRIGHT_GREEN "loaded ", scalar(@records), " records\n";

foreach my $record (@records) {
 	print sprintf("MANUF((%s), %d, %d, %s, %s),\n", 
 		toCArrayLiteral(@{$record->{MACPrefix}}), 
 		scalar(@{$record->{MACPrefix}}),
 		$record->{MACMask}, 
 		"@" . quote($record->{description}), 
 		($record->{longDescription} ? "@" . quote($record->{longDescription}) : "nil"));

}