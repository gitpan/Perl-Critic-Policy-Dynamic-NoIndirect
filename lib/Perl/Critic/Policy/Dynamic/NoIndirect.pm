package Perl::Critic::Policy::Dynamic::NoIndirect;

use 5.008;

use strict;
use warnings;

=head1 NAME

Perl::Critic::Policy::Dynamic::NoIndirect - Perl::Critic policy against indirect method calls.

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';

=head1 DESCRIPTION

This L<Perl::Critic> dynamic policy reports any use of indirect object syntax with a C<'stern'> severity.
It's listed under the C<'dynamic'> and C<'maintenance'> themes.

Since it wraps around L<indirect>, it needs to compile the audited code and as such is implemented as a subclass of L<Perl::Critic::DynamicPolicy>.

=cut

use base qw/Perl::Critic::DynamicPolicy/;

use Perl::Critic::Utils qw/:severities/;

sub default_severity { $SEVERITY_HIGH }
sub default_themes   { qw/dynamic maintenance/ }
sub applies_to       { 'PPI::Document' }

sub violates_dynamic {
 my ($self, undef, $doc) = @_;

 my $src;

 if ($doc->isa('PPI::Document::File')) {
  my $file = $doc->filename;
  open my $fh, '<', $file
      or do { require Carp; Carp::confess("Can't open $file for reading: $!") };
  $src = do { local $/; <$fh> };
 } else {
  $src = $doc->serialize;
 }

 my @errs;
 my $offset  = 6;
 my $wrapper = <<" WRAPPER";
 {
  return;
  package main;
  no indirect hook => sub { push \@errs, [ \@_ ] };
  {
   ;
   $src
  }
 }
 WRAPPER

 {
  local ($@, *_);
  eval $wrapper; ## no critic
  if ($@) {
   require Carp;
   Carp::confess("Couldn't compile the source wrapper: $@");
  }
 }

 my @violations;

 if (@errs) {
  my %errs_tags;
  for (@errs) {
   my ($obj, $meth, $line) = @$_[0, 1, 3];
   $line -= $offset;
   my $tag = join "\0", $line, $meth, $obj;
   push @{$errs_tags{$tag}}, [ $obj, $meth ];
  }

  $doc->find(sub {
   my $elt = $_[1];
   my $pos = $elt->location;
   return 0 unless $pos;

   my $tag = join "\0", $pos->[0], $elt, $elt->snext_sibling;
   if (my $errs = $errs_tags{$tag}) {
    push @violations, do { my $e = pop @$errs; push @$e, $elt; $e };
    delete $errs_tags{$tag} unless @$errs;
    return 1 unless %errs_tags;
   }

   return 0;
  });
 }

 return map {
  my ($obj, $meth, $elt) = @$_;
  $self->violation(
   "Indirect call of method \"$meth\" on object \"$obj\"",
   "You really wanted $obj\->$meth",
   $elt,
  );
 } @violations;
}

=head1 DEPENDENCIES

L<perl> 5.8, L<Carp>.

L<Perl::Critic>, L<Perl::Critic::Dynamic>.

L<indirect>.

=head1 AUTHOR

Vincent Pit, C<< <perl at profvince.com> >>, L<http://www.profvince.com>.

You can contact me by mail or on C<irc.perl.org> (vincent).

=head1 BUGS

Please report any bugs or feature requests to C<bug-perl-critic-policy-dynamic-noindirect at rt.cpan.org>, or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Perl-Critic-Policy-Dynamic-NoIndirect>.
I will be notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Perl::Critic::Policy::Dynamic::NoIndirect 

=head1 COPYRIGHT & LICENSE

Copyright 2009 Vincent Pit, all rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1; # End of Perl::Critic::Policy::Dynamic::NoIndirect
