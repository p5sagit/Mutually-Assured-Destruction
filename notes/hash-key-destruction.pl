#!/usr/bin/env perl

use strict;
use warnings;
use Variable::Magic qw(wizard cast);

BEGIN { package Foo; sub DESTROY { warn "in DESTROY\n"; } }

my $wiz = wizard data => sub { $_[1] },
                 free => sub { warn "destroyed $_[1]!\n"; };

my %objs;

$objs{foo} = bless({}, 'Foo');

cast $objs{foo}, $wiz, '$objs{foo}';

delete $objs{foo};
