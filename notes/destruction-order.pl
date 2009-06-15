#!/usr/bin/env perl

use strict;
use warnings;
use Variable::Magic qw(wizard cast);

BEGIN { package Foo; sub DESTROY { warn "in DESTROY\n"; } }

my $wiz = wizard data => sub { $_[1] },
                 free => sub { warn "destroyed $_[1]!\n"; };

{
  warn "Stanza 1\n";

  my %foo;
  
  my $foo = \%foo;
  
  bless($foo, 'Foo');
  
  cast $foo, $wiz, '$foo';
  cast %foo, $wiz, '%foo';

}

{
  warn "Stanza 2\n";
  
  my $foo = do {
    my %foo;
    cast %foo, $wiz, '%foo';
    \%foo;
  };
  
  bless($foo, 'Foo');
  
  cast $foo, $wiz, '$foo';

  undef($foo);

  warn "End of block\n";

}
