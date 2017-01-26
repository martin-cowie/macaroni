#!/usr/bin/env perl -w
use strict;
use ManufParser;
use Term::ANSIColor 2.00 qw(:pushpop);
use Data::Dumper;


sub toSqlBlob {
	return sprintf("X'%s'", join("", @_));
}

sub quote {
	return "\"$_[0]\"";
}

sub escapeSQL {
	my ($result) = @_;
	return $result unless($result);

	$result =~ s/(\')/''/g;
	return $result;
}

die "wrong # args, try $0 filename" unless (1 == @ARGV);
my $filename = $ARGV[0];

print STDERR PUSHCOLOR BRIGHT_GREEN "Loading $filename\n";

open(my $fh, "<$filename") or die "Cannot open $filename: $!";
my $parser = new ManufParser($fh);
my @records = $parser->parse();

print STDERR PUSHCOLOR BRIGHT_GREEN "loaded ", scalar(@records), " records\n";

# Output
print STDERR PUSHCOLOR BRIGHT_GREEN "Outputing " . scalar(@records) . " records\n";
print "create table manufacturers(description TEXT NOT NULL, longDescription TEXT, MACPrefix BLOB, MACMask INTEGER, CONSTRAINT u_constraint UNIQUE(MACPrefix, MACMask));\n";
foreach my $record (@records) {
	print sprintf("insert into manufacturers(description, longDescription, MACPrefix, MACMask) values('%s', %s, %s, %d);\n", 
		escapeSQL($record->{description}), 
		($record->{longDescription} ? quote(escapeSQL($record->{longDescription})): "NULL"),
		toSqlBlob(@{$record->{MACPrefix}}),
		$record->{MACMask}
		);
}