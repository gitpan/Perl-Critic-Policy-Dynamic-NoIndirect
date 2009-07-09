#!perl

use strict;
use warnings;

use blib;

use Perl::Critic::TestUtils qw/pcritique_with_violations/;
Perl::Critic::TestUtils::block_perlcriticrc();

my $code = shift || exit;

print for eval { pcritique_with_violations('Dynamic::NoIndirect', \$code) };
