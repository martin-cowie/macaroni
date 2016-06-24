#!/usr/bin/env perl -w
use strict;

sub trim {
	my($str) = @_;
	return $str unless($str);
	$str =~ s/^\s+|\s+$//g;
	return $str;
}

sub toArrayLiteral {
	my (@integers) = @_;
	return sprintf("(unsigned char[]){%s}", join(", ", map({"0x" . $_} @integers)));
}

sub quote {
	return "\"$_[0]\"";
}

die "wrong # args, try $0 filename" unless (1 == @ARGV);
my $filename = $ARGV[0];

print STDERR "Loading $filename\n";

open(my $fh, "<$filename") or die "Cannot open $filename: $!";
while(<$fh>) {
	chomp;

	# Skip comments
	next if(/^\s*#/);
	# Skip empty lines
	next if(/^\s*$/);

	# TODO: detect the width from the numebr of bytes, unless a /qualifier is given

	if(/^([0-9A-F-:]+)	# $1 The MAC address
		(\/(\d+))?		# $3 The optional qualifier
		(.+)			# $4 The short & long descriptions
		/ix) {
		my($macStr, $qualifier, $descriptions) = ($1, $3, $4);
		my @parts = split /\#/, $descriptions, 2;
		my($description, $longDescription) = (trim($parts[0]), trim($parts[1]));
		my @macBytes = split /[-:]/, $macStr;

		my $macMask = $qualifier ? $qualifier : (8 * scalar(@macBytes));

	 	print sprintf("MANUF((%s), %d, %d, %s, %s),\n", 
	 		toArrayLiteral(@macBytes), 
	 		scalar(@macBytes),
	 		$macMask, 
	 		"@" . quote($description), 
	 		($longDescription ? "@" . quote($longDescription) : "nil"));
	 	next;
	}

	print STDERR "Cannot parse: $_\n";
}