use Test::More tests => 17;
use 5.010;
use strict;
use warnings;
use ManufTreeBuilder;

# Node tests
my $node = Node->new();
my $newNode = Node->new();
ok( defined $node && ref $node eq 'Node', "Constructor works");
ok( $node->nodeNumber() eq 0 && $newNode->nodeNumber() eq 1, 'nodeNumber accessor works');

# LeafNode tests
my $record = {
	descrition => 'description', 
	longDescription => 'longDescription',
	MACPrefix => [1,2],
	MACMask => 16,
	lineNumber => 44
};


my $leafNode = LeafNode->new($record, [1,2]);
ok( defined $leafNode && ref $leafNode eq 'LeafNode', "LeafNode constructor works");
ok( $leafNode->nodeNumber() eq 2, "LeafNode::nodeNumber accesor works");
is_deeply( $leafNode->branchValues , [1,2], "branchValues should be [1,2]");

# BranchNode tests
my $branchNode = BranchNode->new();
ok( defined $branchNode && ref $branchNode eq 'BranchNode', "BranchNode constructor works");
ok($branchNode->nodeNumber() eq 3, "BranchNode::nodeNumber accesor works");
is_deeply($branchNode->branches(), {}, "branches should be empty");

# Two level insert
$branchNode->insert($leafNode);
ok(keys %{$branchNode->branches} eq (1) && 
	ref $branchNode->branches->{1} eq 'BranchNode', "BranchNode has correct child");

ok(keys %{$branchNode->branches->{1}->branches} eq (1) && 
	ref $branchNode->branches->{1}->branches->{2} eq 'LeafNode', 'LeafNode has correct grandchild');

# Inserting at the same level
$branchNode->insert(new LeafNode($record, [1,6]));
my @sortedKeys = sort keys %{$branchNode->branches->{1}->branches};
is_deeply(\@sortedKeys, [2,6], "BranchNode has correct number of children");
is(ref $branchNode->branches->{1}->branches->{6}, 'LeafNode', "Child 6 is correct type");

ok($branchNode->isContiguous, "BranchNode with single child is contiguous");

$branchNode = new BranchNode();
$branchNode->insert(new LeafNode($record, [1]));
$branchNode->insert(new LeafNode($record, [3]));
ok(!$branchNode->isContiguous , "BranchNode with two children is not contiguous");

$branchNode = new BranchNode();
$branchNode->insert(new LeafNode($record, [0x0A]));
$branchNode->insert(new LeafNode($record, [0x0B]));
ok($branchNode->isContiguous , "BranchNode with two children is contiguous");

# TreeBuilder tests
my $treeBuilder =  new ManufTreeBuilder();
$treeBuilder->insert($record);

ok(keys %{$treeBuilder->root->branches} eq (1) && 
	ref $treeBuilder->root->branches->{1} eq 'BranchNode', "BranchNode has correct child");

ok(keys %{$treeBuilder->root->branches->{1}->branches} eq (1) && 
	ref $treeBuilder->root->branches->{1}->branches->{2} eq 'LeafNode', 'LeafNode has correct grandchild');
