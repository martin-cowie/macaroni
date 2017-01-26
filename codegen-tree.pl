#!/usr/bin/env perl -w
use strict;
use Getopt::Std;
use ManufParser;
use Term::ANSIColor 2.00 qw(:pushpop);
use Data::Dumper;
use Scalar::Util qw(blessed);

# sub toCArrayLiteral {
# 	my (@integers) = @_;
# 	return sprintf("(unsigned char[]){%s}", join(", ", map({"0x" . $_} @integers)));
# }

# sub quote {
# 	return "\"$_[0]\"";
# }

die "wrong # args, try $0 filename" unless (1 == @ARGV);
my $filename = $ARGV[0];

print STDERR PUSHCOLOR BRIGHT_GREEN "Loading $filename\n";

open(my $fh, "<$filename") or die "Cannot open $filename: $!";
my $parser = new ManufParser($fh);
my @records = $parser->parse();

print STDERR PUSHCOLOR BRIGHT_GREEN "loaded ", scalar(@records), " records\n";

# Produces about 10M of data
# print new Data::Dumper([\@records], ["records"])->Indent(0)->Dump;

sub insert {
	my ($bytes, $record, $tree) = @_;
	my $byte = shift(@$bytes);
	if (@$bytes > 0) {
		# Create the empty record if needed
		$tree->{$byte} = {} unless (exists $tree->{$byte});

		# recurse over remaining numbers
		insert($bytes, $record, $tree->{$byte})
	} else {
		# Nasty use of `bless` to show this is a terminal 'record' node not a routing node.
		my $slimRecord = bless {
			lineNumber => $record->{lineNumber},
			description => $record->{description},
			longDescription => $record->{longDescription},
			MACMask => $record->{MACMask}
		}, "leaf";
		$tree->{$byte} = $slimRecord;
	}
}

my $tree = {};

foreach my $record (@records) {
	my @macPrefix = @{$record->{MACPrefix}};
	insert(\@macPrefix, $record, $tree);
}

print new Data::Dumper([$tree], ["tree"])->Sortkeys(1)->Dump;

# TODO: how many branch nodes have contiguous values, and how many do not?

sub analyse {
	my ($tree) = @_;

	# Not a routing node
	return (0, 0, 0) if (blessed $tree);

	# Count the child nodes
	my $count = 0; my $contiguous = 0; my $singleNodes =0;
	while (my ($key, $value) = each %$tree) {
		my ($childCount, $childContiguous, $childSingleNodes) = analyse($value);
		$count += $childCount;
		$contiguous += $childContiguous;
		$singleNodes += $childSingleNodes;
	}

	return (1 + $count, 
		(isContiguous($tree) ? 1 :0) + $contiguous, 
		$singleNodes + (keys($tree) == 1 ? 1 : 0));
}


sub isContiguous {
	my ($tree) = @_;

	# Are keys contiguous?
	my @keys = sort keys %$tree;
	for(my $i=1; $i<@keys; $i++) {
		my ($value, $lastValue) = (hex($keys[$i]), hex($keys[$i -1]));
		return 0 unless($lastValue +1 == $value);
	}

	return 1;
}


my ($count, $contiguous, $singleNode) = analyse($tree);
print STDERR "nodes: $count, contiguous: $contiguous, single routing nodes: $singleNode\n";

