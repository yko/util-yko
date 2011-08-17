package Util::YKO::Starter;
use warnings;
use strict;

use File::Spec;
require Carp;

sub ignores_guts {
    my $self = shift;

    if ($self->{template_dir} && -d $self->{template_dir}) {
        my $file = File::Spec->catfile($self->{template_dir}, 'ignore.txt');
        if (-f $file) {
            open my $FH, '<', $file or Carp::croak($!);
            local $/;
            return <$FH>;
        }
    }

    return $self->SUPER::ignores_guts;
}

1;

__END__

=head1 NAME

Util::YKO::Starter - Module::Starter plugin


=head1 SYNOPSIS

TODO

=head1 DESCRIPTION

Small Module::Starter plugin that generates ignores content
from file 'ignore.txt' in 'template_dir'

=head1 FUNCTIONS

L<Util::YKO::Starter> defines following functions:

=head2 ignores_guts

    $self->ignores_guts

Returns content to ignore

=head1 LICENCE AND COPYRIGHT

Copyright (C) 2011, Yaroslav Korshak.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
