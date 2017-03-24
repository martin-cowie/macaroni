package ManufParser;

=head1 NAME

ManufParser. Parse the file manuf.txt that comprises part of the Wireshark distribution.

=head1 SYNOPSIS

    use ManufParser;

    open(my $fh, "<$filename") or die "Cannot open $filename: $!";
    my $parser = new ManufParser($fh);
    my @records = $parser->parse();

=head1 CONSTRUCTOR

Argument `fh` is an open filehandle.

=head1 METHODS

=head2 parse

Returns an unordered array of records

=head2 OUTLOOK

Ideally needs to be drawn from the same sources that manuf.txt is drawn ...

http://standards.ieee.org/develop/regauth/oui/oui.txt
http://standards.ieee.org/develop/regauth/iab/iab.txt
http://standards.ieee.org/develop/regauth/oui28/oui28.txt
http://standards.ieee.org/develop/regauth/oui36/oui36.txt

CSV editions available for many.

=cut

use strict;
use warnings;

sub new {
	my ($class, $fh) = @_;

	my $self = bless {
		fh => $fh
	}, $class;
	return $self;
}

sub trim {
	my($str) = @_;
	return $str unless($str);
	$str =~ s/^\s+|\s+$//g;
	return $str;
}

sub parse {
	my $self = shift;
	my $lineNumber = 0;
	my @result;

	my $fh = $self->{fh};
	while(my $line = <$fh>) {
		chomp($line);
		$lineNumber++;

		# Skip comments and empty lines
		next if($line =~ /^\s*#/ or $line =~ /^\s*$/);

		if($line =~ /^([0-9A-F-:]+)	# $1 The MAC address
					(\/(\d+))?		# $3 The optional qualifier
					(.+)			# $4 The short & long descriptions
					/ix) {
			my($macStr, $qualifier, $descriptions) = ($1, $3, $4);
			my @parts = split /\#/, $descriptions, 2;
			my($description, $longDescription) = (trim($parts[0]), trim($parts[1]));
			my @macBytes = split /[-:]/, $macStr;

			# Trim MACPrefix by the qualifier, e.g. a qualifier of 16 will get you only bytes 1 and 2 of @macBytes
			@macBytes = splice(@macBytes, 0, calcBytesForBits($qualifier)) if ($qualifier);

			my $macMask = $qualifier ? $qualifier : (8 * scalar(@macBytes));

			my $record = {
				# The description field
				description => ($longDescription ? $longDescription : $description),

				# The hex bytes indentifying the manufacturer
				MACPrefix => \@macBytes,

				# The number of bits in `MACPrefix` (not always a multiple of 8)
				MACMask => $macMask,

				# The line number where this record was parsed
				lineNumber => $lineNumber,

				# A human readable description of the mapping
				mapping => $line
			};
			push @result, $record;
		 	next;

		}
		die "Cannot parse: $_\n";
	}
	return @result;
}

sub calcBytesForBits {
	my($qualifier) = @_;
	return ($qualifier >> 3) + ($qualifier % 8 ? 1 : 0);	
}

1; 