#!/usr/bin/env perl

use strict;
use warnings;
use Devel::GlobalDestruction ();
use Scalar::Util ();
use Variable::Magic ();
use Carp ();

BEGIN {
  package Foo;

  my $wiz;
  $wiz = Variable::Magic::wizard
    data => sub { $_[1] },
    get => sub {
      Carp::cluck "get fired";
      Variable::Magic::dispell ${$_[0]}, $wiz;
    };

  sub DESTROY {
    return if Devel::GlobalDestruction::in_global_destruction();
    warn "DESTROY\n";

    my $self = shift;

    if (ref $self->{other_side} && $self->{other_side}{reference}) {
      if (
        Scalar::Util::refaddr($self->{other_side}{reference})
        eq Scalar::Util::refaddr($self)
      ) {
        warn "Enlivening";
        $self->{other_side}{reference} = $self;
        Variable::Magic::cast $self->{other_side}{reference}, $wiz;
        delete $self->{other_side};
      }
    }
  }
}

my $near = {};
my $far = $near->{reference} = bless({ other_side => $near }, 'Foo');
warn $near->{reference};
warn $far;
Scalar::Util::weaken($near->{reference});
warn "Setup done\n";
undef($far);
warn $near->{reference};
warn $near->{reference};
Scalar::Util::weaken($near->{reference});
warn $near->{reference};
