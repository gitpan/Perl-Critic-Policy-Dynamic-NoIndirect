use 5.008;

use strict;
use warnings;
use ExtUtils::MakeMaker;

my $dist = 'Perl-Critic-Policy-Dynamic-NoIndirect';

my %META = (
 configure_requires => {
  'ExtUtils::MakeMaker' => 0,
 },
 build_requires => {
  'ExtUtils::MakeMaker'     => 0,
  'Perl::Critic::TestUtils' => 0,
  'Test::More'              => 0,
 },
 resources => {
  bugtracker => "http://rt.cpan.org/NoAuth/ReportBug.html?Queue=$dist",
  homepage   => "http://search.cpan.org/dist/$dist/",
  license    => 'http://dev.perl.org/licenses/',
  repository => "http://git.profvince.com/?p=perl%2Fmodules%2F$dist.git",
 },
);

WriteMakefile(
    NAME             => 'Perl::Critic::Policy::Dynamic::NoIndirect',
    AUTHOR           => 'Vincent Pit <perl@profvince.com>',
    LICENSE          => 'perl',
    VERSION_FROM     => 'lib/Perl/Critic/Policy/Dynamic/NoIndirect.pm',
    ABSTRACT_FROM    => 'lib/Perl/Critic/Policy/Dynamic/NoIndirect.pm',
    PL_FILES         => {},
    PREREQ_PM        => {
        'Carp'                        => 0,
        'Perl::Critic::Utils'         => 0,
        'Perl::Critic::DynamicPolicy' => 0,
        'base'                        => 0,
        'indirect'                    => '0.15',
    },
    MIN_PERL_VERSION => 5.008,
    META_MERGE       => \%META,
    dist             => {
        PREOP      => 'pod2text lib/Perl/Critic/Policy/Dynamic/NoIndirect.pm > $(DISTVNAME)/README',
        COMPRESS   => 'gzip -9f', SUFFIX => 'gz'
    },
    clean            => {
        FILES => "$dist-* *.gcov *.gcda *.gcno cover_db Debian_CPANTS.txt"
    },
);
