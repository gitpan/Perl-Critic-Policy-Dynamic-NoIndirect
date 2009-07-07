#!perl -T

use strict;
use warnings;

my $subtests;
BEGIN { $subtests = 3 }

use Test::More tests => $subtests * 14;

use Perl::Critic::TestUtils qw/pcritique_with_violations/;

Perl::Critic::TestUtils::block_perlcriticrc();

my $policy = 'Dynamic::NoIndirect';

{
 local $/ = "####";

 my $id = 1;

 while (<DATA>) {
  s/^\s+//s;

  my ($code, $expected) = split /^-+$/m, $_, 2;
  my @expected = eval $expected;

  my @violations = eval { pcritique_with_violations($policy, \$code) };

  if ($@) {
   diag "Compilation $id failed: $@";
   next;
  }

  for my $v (@violations) {
   my $exp = shift @expected;

   unless ($exp) {
    fail "Unexpected violation for chunk $id: " . $v->description;
    next;
   }

   my $pos = $v->location;
   my ($meth, $obj, $line, $col) = @$exp;

   like $v->description,
        qr/^Indirect call of method \"\Q$meth\E\" on object \"\Q$obj\E\"/,
        "description $id";
   is   $pos->[0], $line, "line $id";
   is   $pos->[1], $col,  "column $id";
  }

  ++$id;
 }
}

__DATA__
my $x = new X;
----
[ 'new', 'X', 1, 9 ]
####
my $x = new X; $x = new X;
----
[ 'new', 'X', 1, 9 ], [ 'new', 'X', 1, 21 ]
####
my $x = new X    new X;
----
[ 'new', 'X', 1, 9 ], [ 'new', 'X', 1, 18 ]
####
my $x = new X;
my $y = new X;
----
[ 'new', 'X', 1, 9 ], [ 'new', 'X', 2, 9 ]
####
our $obj;
my $x = new $obj;
----
[ 'new', '$obj', 2, 9 ]
####
our $obj;
my $x = new $obj; $x = new $obj;
----
[ 'new', '$obj', 2, 9 ], [ 'new', '$obj', 2, 24 ]
####
our $obj;
my $x = new $obj    new $obj;
----
[ 'new', '$obj', 2, 9 ], [ 'new', '$obj', 2, 21 ]
####
our $obj;
my $x = new $obj;
my $y = new $obj;
----
[ 'new', '$obj', 2, 9 ], [ 'new', '$obj', 3, 9 ]

