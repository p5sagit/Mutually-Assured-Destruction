#!/usr/bin/env perl

use strict;
use warnings;
use Devel::GlobalDestruction ();

my %objs;

BEGIN {
  package Foo;

  sub DESTROY {
    warn "DESTROY\n";
    return if Devel::GlobalDestruction::in_global_destruction();
    $objs{$_[0]} = $_[0];
  }
}

{
  bless({}, 'Foo');
}

warn join(', ', %objs);
