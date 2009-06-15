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
      Scalar::Util::weaken($_[1]->{reference}{other_side} = ${$_[0]});
      Scalar::Util::weaken($_[1]->{reference});
      Variable::Magic::dispell ${$_[0]}, $wiz;
    };

  sub DESTROY {
    return if Devel::GlobalDestruction::in_global_destruction();
    Carp::cluck "DESTROY\n";

    my $self = shift;

    if (ref $self->{other_side} && $self->{other_side}{reference}) {
      if (
        Scalar::Util::refaddr($self->{other_side}{reference})
        eq Scalar::Util::refaddr($self)
      ) {
        warn "Enlivening";
        $self->{other_side}{reference} = $self;
        Variable::Magic::cast(
          $self->{other_side}{reference}, $wiz, $self->{other_side}
        );
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
my $copy = $near->{reference};
warn $copy;
warn Scalar::Util::isweak($near->{reference});
warn $near->{reference};
warn $near->{reference};
undef($near);
warn "Done\n";
