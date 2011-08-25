package Util::YKO::GetTag;

use warnings;
use strict;
require Carp;
use overload '""' => sub { ${$_[0]} }, fallback => 1;
use Scalar::Util 'readonly';

our $VERSION = 0.03;

sub new {
    my $class = ref $_[0] ? ref $_[0] : $_[0];

    if (readonly $_[1]) {
        my $value = $_[1];
        return bless \$value, $class;
    }

    bless ref $_[1] ? $_[1] : \$_[1], $class;
}

sub _self {
    UNIVERSAL::isa($_[0], __PACKAGE__) ? $_[0] : __PACKAGE__->new($_[0]);
}

sub get_tag(\$$;%) {
    my ($tag, %opts) = @_[1..$#_];
    my $self = &_self;

    my $startregexp = "<\Q$tag\E";
    my $key;
    if (exists $opts{id}) {
        $key = 'id';
    } elsif (%opts) {
        $key = (keys %opts)[0];
    }

    if ($key) {
        $startregexp .= "\\s+[^>]*?\Q${key}\E=([\"'])";
        if (UNIVERSAL::isa($opts{$key}, 'Regexp')) {
            $startregexp .= $opts{$key};
        } else {
            $startregexp .= quotemeta $opts{$key};
        }
        $startregexp .= "\\1";
        delete $opts{$key};
    }
    $startregexp .= '.*?(/?)>';

  OPTS: while ($$self =~ /$startregexp/gsc) {

        my $startpos = $-[0];
        my $endpos   = $+[0];

        # Empty tag like <div />
        if ($2) {
            my $child = $self->child($startpos, $endpos - $startpos);
            return wantarray ? ($child, $startpos, $endpos) : $child;
        }

        my $level = 1;
        while ($level && ($$self =~ m#<(/?)\Q$tag\E.*?>#gsc)) {
            $endpos = $+[0];
            $1 ? $level-- : $level++;
        }

        my $child = $self->child($startpos, $endpos - $startpos);
        foreach my $o (keys %opts) {
            if ($$child !~ /<$tag[^>]+\Q$o\E=(["'])\Q$opts{$o}\E\1/) {
                pos($$child) = $startpos;
                redo OPTS;
            }
        }

        return wantarray ? ($child, $startpos, $endpos) : $child;
    }
    undef;
}

sub child {
    ref($_[0])->new( substr ${$_[0]}, $_[1], $_[2] );
}

sub get_tag_inner(\$$;%) {
    my @result = &get_tag;
    return unless $result[0];

    $result[0] =~ s#^<\Q$_[1]\E(?:\s+[^>]*?)?>##s;
    $result[0] =~ s#</\Q$_[1]\E\s*>##s;

    return wantarray ? @result : $result[0];
}

sub import {
    my $caller = caller;
    no strict 'refs';
    *{"${caller}::get_tag"} = \&get_tag;
    *{"${caller}::get_tag_inner"} = \&get_tag_inner;
}

sub reset {
    my $self = &_self;
    pos($$self) = 0;
    $self;
}

1;

__END__

=head1 NAME

Util::YKO::GetTag - get single tag content from HTML string


=head1 SYNOPSIS

    use Util::YKO::GetTag;

    my $tag1 = get_tag $string, $tagname, %options;
    my $tag2 = get_tag $string, div, id    => 'foo';
    my $tag3 = get_tag $string, div, class => 'bar';


=head1 DESCRIPTION

Not very relaible tool that allows to get tag content from XML-like documents.
Comment and CDATA tags are not respected.

=head1 FUNCTIONS

L<Util::YKO::GetTag> exports following functions:

=head2 get_tag

    my $tag = get_tag $html, $tag, %options;
    my $tag = get_tag $html, $tag, id => 'foo', class => 'bar';

    my ($tag, $start, $end) = get_tag $html, $tag, %options;

In scalar context returns tag content.

In list context returns tag content,
start pos and end pos in original html string

As options accepts list of tag attributes

=head2 get_tag_inner

    my $tag = get_tag_inner $html, $tag, %options;
    my $tag = get_tag_inner $html, $tag, id => 'foo', class => 'bar';

    my ($tag, $start, $end) = get_tag_inner $html, $tag, %options;

In scalar context returns tag inner content.

In list context returns tag inner content,
start pos and end pos in original html string

As options accepts list of tag attributes

=head1 LICENCE AND COPYRIGHT

Copyright (C) 2011, Yaroslav Korshak.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
