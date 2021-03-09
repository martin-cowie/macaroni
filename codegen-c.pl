#!/usr/bin/env perl
use strict;
use Getopt::Std;
use Term::ANSIColor 2.00 qw(:pushpop);
use Scalar::Util qw(blessed);
use File::Basename;
use lib dirname (__FILE__);
use ManufParser;
use ManufTreeBuilder;

sub quoteCLiteral {
	return "\"$_[0]\"";
}

die "wrong # args, try $0 filename" unless (1 == @ARGV);
my $filename = $ARGV[0];

print STDERR PUSHCOLOR BRIGHT_GREEN "Loading $filename\n";

open(my $fh, "<$filename") or die "Cannot open $filename: $!";
my $parser = new ManufParser($fh);
my @records = $parser->parse();
close($fh);

print STDERR PUSHCOLOR BRIGHT_GREEN "Loaded ", scalar(@records), " records\n";

my $treeBuilder = new ManufTreeBuilder();
foreach my $record (@records) {
	$treeBuilder->insert($record);
}

# Compose & print the string table
my $strings = $treeBuilder->strings();
my %stringsByIndex = map {$strings->{$_} => $_} keys %$strings;
my @stringTable;
for(my $i=0; $i< scalar(keys %stringsByIndex); $i++) {
	push @stringTable, quoteCLiteral($stringsByIndex{$i});
}

print "#include \"macaroni.h\"\n\n";
print "#include \"macaroni_internal.h\"\n\n";
print "const char * const stringTable[] = {", join(",\n\t\t", @stringTable), "};\n\n";

# Pring the leaf nodes
sub mapTree {
	my ($node, $leafFunc, $branchFunc) = @_;

	if ($node->hasBranches) {
		while (my ($key, $value) = each %{$node->branches}) {
			mapTree($value, $leafFunc, $branchFunc);
		}
		&$branchFunc($node);
	} else {
		&$leafFunc($node);
	}
}

my $stringsByName = $treeBuilder->strings();
my $leafCount = 0;

mapTree($treeBuilder->root(), sub {
		my($node) = @_;
		my($lineNumber, $shortDescriptionIndex) = (
			$node->record->{lineNumber},
			$stringsByName->{$node->record->{description}}
		);
		my $descriptionIndex = $stringsByName->{$node->record->{description}} ;
		my $nodeNumber = $node->nodeNumber;

		my $mappingString = $node->record->{mapping};
		$leafCount++;

		print <<FIN;
/* $mappingString */
static type_node_t node_$nodeNumber = {
	.node_type = leaf,
	.value = {
		.leaf_node = {
			.description = $descriptionIndex,
		}
	}
};

FIN
	}, sub {
		my ($node) = @_;
		my $nodeNumber = $node->nodeNumber;

		my @branchKeys = sort keys %{$node->branches};
		my $tableLength = scalar @branchKeys;
		my $lastIndex = $tableLength -1; # tableLength can go up to 256, which does not fit in a char

		if ($node->isContiguous) {
			my $firstKey = $branchKeys[0];
			my $lastKey = sprintf("%02X", $lastIndex);
			my $valuesSource = join(", ", map {"&node_" . $node->branches->{$_}->nodeNumber} @branchKeys);

			print <<FIN;
static const type_node_t *values_${nodeNumber}[] = {$valuesSource};
static const type_node_t node_$nodeNumber = {
	.node_type = contiguous,
	.value = {
		.contiguous_node = {
			.first_index = 0x${firstKey},
			.last_index = 0x${lastKey},
			.values = (const struct type_node_t **)&values_${nodeNumber}
		}
	}
};

FIN
		} else {
			my $tableSource = join(", ", map {
				"{0x$_, &node_" . $node->branches->{$_}->nodeNumber . "}"
			} @branchKeys );
			print "\nstatic const bytemap_elem_t table_${nodeNumber}[] = {$tableSource};\n";

			print <<FIN;
static const type_node_t node_$nodeNumber = {
	.node_type = byte_map,
	.value = {
		.bytemap_node = {
			.last_index = $lastIndex,
			.table = table_$nodeNumber
		}
	}
};

FIN
		}

	});

print "const type_node_t *root_node = &node_0;\n";

print STDERR "Counted $leafCount leaves\n";
print STDERR RESET "";
