#!/usr/bin/env perl

use strict;
use warnings;
use Scalar::Util qw(weaken isweak);

# $X strong -> $Y
# $Y weak   -> $X
#
# $Y goes out of scope - all fine
#
# $X goes out of scope - need to swap to
#
# $X weak   -> $Y
# $Y strong -> $X
#
# but not if $Y is already out of scope - so don't do it unless $Y's refcount
# is >1

BEGIN {
  package Foo;

  use Devel::GlobalDestruction 'in_global_destruction';
  use Scalar::Util qw(weaken isweak);
  use Devel::Refcount qw(refcount);

  sub DESTROY {
    my $self = shift;
    warn "DESTROY fired for $self\n";
    return if in_global_destruction;
    warn "Not in global destruction\n";
    return unless isweak $self->{back}{forward};
    warn "Reference to us is weak\n";
    return unless $self->{forward};
    warn "Have forward pointer\n";
    return unless refcount($self->{forward}) > 1;
    warn "Next in chain has refcount of ".(refcount $self->{forward})."\n";
    $self->{back}{forward} = $self; #->{back}{forward};
    weaken $self->{forward};
    warn "Swapped links - $self now has weak ref to ${\$self->{forward}} and ${\$self->{back}} has a strong ref to $self\n";
    return;
  }
}

# set this shit up
my $one = bless({}, 'Foo');
my $two = bless({}, 'Foo');
weaken(my $weak_one = $one);
weaken(my $weak_two = $two);
$one->{forward} = $two;
weaken($two->{forward} = $one);
weaken($one->{back} = $two);
weaken($two->{back} = $one);

sub status {
  warn "One: ${\($weak_one||'GONE')} Two: ${\($weak_two||'GONE')}\n";
  warn "One's forward is${\(isweak($weak_one->{forward}) ? '' : ' not')} weak\n" if $weak_one;
  warn "Two's forward is${\(isweak($weak_two->{forward}) ? '' : ' not')} weak\n" if $weak_two;
}

warn "\$one is $one, \$two is $two";
warn "Undefining \$two\n";
undef($two);
status;
warn "Restoring \$two\n";
$two = $weak_two;
warn "Undefining \$one\n";
undef($one);
status;
warn "Restoring \$one\n";
$one = $weak_one;
warn "Undefining \$two\n";
undef($two);
status;
warn "Restoring \$two\n";
$two = $weak_two;
warn "Undefining both\n";
undef($one);
undef($two);
status;
warn "Done\n";
