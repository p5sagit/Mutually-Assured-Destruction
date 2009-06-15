#!/usr/bin/env perl

use strict;
use warnings;
use Devel::GlobalDestruction ();
use Scalar::Util ();

BEGIN {
  package Foo;

  sub DESTROY {
    return if Devel::GlobalDestruction::in_global_destruction();
    warn "DESTROY\n";

    my $self = shift;

    if (ref $self->{other_side}) {
      if (
        Scalar::Util::refaddr($self->{other_side}{reference})
        eq Scalar::Util::refaddr($self)
      ) {
        warn "Enlivening";
        $self->{other_side}{reference} = $self;
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
Scalar::Util::weaken($near->{reference});
warn $near->{reference};
