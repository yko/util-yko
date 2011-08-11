package Util::YKO::GetTag;

use warnings;
use strict;
require Carp;

our $VERSION = 0.0101;

sub get_tag(\$$;%) {
    my ($html, $tag, %opts) = @_;
    my $startregexp = "<\Q$tag\E";

    my $key;
    if (exists $opts{id}) {
        $key = 'id';
    } elsif (%opts) {
        $key = (keys %opts)[0];
    }

    if ($key) {
        $startregexp .= "[^>]+\Q${key}\E=([\"'])";
        if (UNIVERSAL::isa($opts{$key}, 'Regexp')) {
            $startregexp .= $opts{$key};
        } else {
            $startregexp .= quotemeta $opts{$key};
        }
        $startregexp .= "\\1";
        delete $opts{$key};
    }
    $startregexp .= '.*?(/?)>';

  OPTS: while ($$html =~ /$startregexp/gsc) {

        my $startpos = $-[0];
        my $endpos   = $+[0];

        # Empty tag like <div />
        if ($2) {
            my $text = substr($$html, $startpos, $endpos - $startpos);
            return wantarray ? ($text, $startpos, $endpos) : $text;
        }

        my $level = 1;
        while ($level && ($$html =~ m#<(/?)\Q$tag\E.*?>#gsc)) {
            $endpos = $+[0];
            $1 ? $level-- : $level++;
        }

        my $text = substr($$html, $startpos, $endpos - $startpos);
        foreach my $o (keys %opts) {
            if ($text !~ /<$tag[^>]+\Q$o\E=(["'])\Q$opts{$o}\E\1/) {
                pos($$html) = $startpos;
                redo OPTS;
            }
        }

        return wantarray ? ($text, $startpos, $endpos) : $text;
    }
    undef;
}

sub import {
    my $caller = caller;
    no strict 'refs';
    *{"${caller}::get_tag"} = \&get_tag;
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

In list context returns tag content, start pos and end pos in original html

As options accepts list of tag attributes

=head1 LICENCE AND COPYRIGHT

Copyright (C) 2011, Yaroslav Korshak.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
