use 5.010;
use strict;
use warnings;

{
	package Node;
	my $nodeNumber = 0;

	sub new {
		my ($class, $record) = @_;
		my $self = bless {
			nodeNumber => $nodeNumber++
		}, $class;
		return $self;
	}

	sub nodeNumber {
		my ($self) = @_;
		return $self->{nodeNumber};
	}
}

{
	package BranchNode;
	@BranchNode::ISA = qw(Node);

	sub new {
		my ($class) = @_;
		my $self = $class->SUPER::new();

		$self->{branches} = {};
		return bless($self, $class);
	}

	sub branches {
		my $self = shift;
		return $self->{branches};
	}

	sub insert {
		my ($self, $leafNode) = @_;
		$self->_insert($leafNode->branchValues(), $leafNode);
	}

	sub _insert {
		my ($self, $bytes, $node) = @_;
		my $byte = uc(shift(@$bytes));

		if (@$bytes == 0) {
			# Insert leaf into this branch
			$self->{branches}->{$byte} = $node;
		} else {
			if (exists $self->{branches}->{$byte}) {
				# Recurse into existing branch
				my $branch = $self->{branches}->{$byte};

				if (ref $branch eq "BranchNode") {
					$branch->_insert($bytes, $node)
				}
			} else {
				# Create a BranchNode under here, and recurse down $bytes.
				my $newBranch = new BranchNode();
				$self->{branches}->{$byte} = $newBranch;
				$newBranch->_insert($bytes, $node);
			}
		}
	}

	# return true if the key values hold no gaps
	sub isContiguous {
		my ($self) = @_;
		my @keys = sort keys %{$self->{branches}};

		return 1 if (1 == @keys);

		for(my $i=1; $i < @keys; $i++) {
			return 0 if hex($keys[$i -1]) +1 != hex($keys[$i]);
		}
		return 1;
	}
}

{
	package LeafNode;
	@LeafNode::ISA = qw(Node);

	sub new {
		my ($class, $record, $branchValues) = @_;
		my $self = $class->SUPER::new();

		$self->{record} = $record;
		$self->{branchValues} = $branchValues;
		return bless($self, $class);
	}

	sub record {
		my $self = shift;
		return $self->{record};
	}

	sub branchValues {
		my $self = shift;
		return $self->{branchValues};
	}
}


package ManufTreeBuilder;

use strict;

sub new {
	my ($class) = @_;

	my $self = bless {
		root => new BranchNode(),
		stringsByName => {}
	}, $class;
	return $self;
}

sub insert {
	my ($self, $record) = @_;

	$self->_insertString($record->{longDescription}) if($record->{longDescription});
	$self->_insertString($record->{description}) if($record->{description});

	# $self->_insert($record->{MACPrefix}, $record, $self->{root});
	my $leafNode = new LeafNode($record, $record->{MACPrefix});
	$self->{leafCount} += $self->{root}->insert($leafNode);
}

# Compose a string table, where each unique string relates to it's position in that table
sub _insertString {
	my ($self, $string) = @_;
	unless(exists $self->{stringsByName}->{$string}) {
		$self->{stringsByName}->{$string} = scalar(keys %{$self->{stringsByName}});
	}
}

sub root {
	my ($self) = @_;
	return $self->{root};
}

sub strings {
	my ($self) = @_;
	return $self->{stringsByName};
}

1;