package Util::YKO::GetTag;

use warnings;
use strict;
require Carp;
use overload '""' => sub { ${$_[0]} }, fallback => 1;
use Scalar::Util 'readonly';
use HTML::Entities;
use CSS::Selector::Parser v0.003;

our $VERSION         = 0.04;
our $TAGNAME_PATTERN = '[_:A-Za-z][-_:A-Za-z0-9]*';

sub new {
    my $class = ref $_[0] ? ref $_[0] : $_[0];

    if (readonly $_[1]) {
        my $value = $_[1];
        return bless \$value, $class;
    }

    bless ref $_[1] ? $_[1] : \$_[1], $class;
}

sub _self {
    UNIVERSAL::isa($_[0], __PACKAGE__) ? shift : __PACKAGE__->new(shift);
}

sub get($;@) {
    my $self = &_self;

    my $wantarray = wantarray;

    my $tag;
    if (@_ % 2) {
        $tag = shift;
        if ($tag !~ /^$TAGNAME_PATTERN$/) {
            return $wantarray
              ? ($self->_get_css($tag))
              : scalar($self->_get_css($tag));
        }
        $tag = quotemeta($tag);
    }
    else {

        # Match-any-tag-name regex
        $tag = $TAGNAME_PATTERN;
    }
    my %opts = @_;

    my $startregexp = "<(?<tagname>$tag)";
    my $key;
    if (exists $opts{id}) {
        $key = 'id';
    }
    elsif (%opts) {
        $key = (keys %opts)[0];
    }

    if ($key) {
        $startregexp .= "\\s+[^>]*?\Q${key}\E=(?<quotechar>[\"'])";
        if (UNIVERSAL::isa($opts{$key}, 'Regexp')) {
            $startregexp .= $opts{$key};
        }
        else {
            $startregexp .= quotemeta $opts{$key};
        }
        $startregexp .= '\k<quotechar>';
        delete $opts{$key};
    }
    $startregexp .= '(?:\s+.*?|\s*?)(?<selfclose>/?)>';

  OPTS: while ($$self =~ /$startregexp/gsc) {

        my $startpos = $-[0];
        my $endpos   = $+[0];

        my $selfclose   = $+{selfclose};
        my $current_tag = $+{tagname};

        # Empty tag like <div />
        if ($selfclose) {

            # Empty tag like <div />
            my $child = $self->child($startpos, $endpos - $startpos);
            return $wantarray ? ($child, $startpos, $endpos) : $child;
        }

        my $level = 1;
        while ($level && ($$self =~ m#<(/?)\Q$current_tag\E.*?>#gsc)) {
            $endpos = $+[0];
            $1 ? $level-- : $level++;
        }

        my $child = $self->child($startpos, $endpos - $startpos);
        foreach my $o (keys %opts) {
            my $re =
              UNIVERSAL::isa($opts{$key}, 'Regexp')
              ? $opts{$o}
              : quotemeta $opts{$o};

            if ($$child !~ /<\Q$current_tag\E[^>]+\Q$o\E=(["'])$re\1/) {
                pos($$child) = $startpos;
                redo OPTS;
            }
        }

        return $wantarray ? ($child, $startpos, $endpos) : $child;
    }

    # Not found
    undef;
}

sub attr(\$$) {
    my $self = &_self;
    my ($attrname) = @_;

    my $pos = pos($$self);
    pos($$self) = 0;
    my $match = $$self
      =~ /^\s*<${TAGNAME_PATTERN}(?:\s+|\s+[^>]*?\s+)\Q$attrname\E([=\s>])/sig;

    my $matchpos = pos($$self);

    unless ($match) {
        pos($$self) = $pos;
        return;
    }

    my $retval = '';

    if ($1 ne '=') {

        # Empty attr
        return $retval;
    }

    my $quotechar = substr $$self, $matchpos, 1;

    if ($quotechar =~ /^['"]$/) {
        ($retval) =
          $$self =~ /\G${quotechar}([^${quotechar}>]*)(?:$quotechar|>)/;

        # FIXME: What if not matched?!
    }
    else {

        # Unquoted attr
        ($retval) = $$self =~ /\G([^\s>]+)/;
        $retval //= '';
    }
    pos($$self) = $pos;

    decode_entities $retval;
}

sub child {
    ref($_[0])->new(substr ${$_[0]}, $_[1], $_[2]);
}

sub inner(\$$;%) {
    my $tag = @_ % 2 ? $TAGNAME_PATTERN : quotemeta($_[1]);
    my @result = &get;

    return unless $result[0];

    $result[0] =~ s#^<$tag(?:\s+[^>]*?)?>##si;
    $result[0] =~ s#</$tag\s*>$##si;

    return wantarray ? @result : $result[0];
}

sub _get_css {
    my $self      = shift;
    my @selectors = CSS::Selector::Parser::parse_selector($_[0]);
    my $wantarray = wantarray;

    my @found;

    my $pos = pos($$self);

    foreach my $selector (@selectors) {
        my $obj = $self->_get_css_by_obj($selector);
        next unless defined $obj;

        return $obj if !$wantarray && defined $obj;

        push @found, [$obj, pos($$self)] if $obj;
        pos($$self) = $pos;
    }

    return $wantarray ? @found : map { $_->[0] } @found;
}

sub _get_css_by_obj {
    my ($self, $obj) = @_;

    my $tag = $self;

  TAG: while ($tag && @$obj) {
        my $cobj = shift @$obj;
        my @args;

        push @args, $cobj->{element} if exists $cobj->{element};

        push @args, id => $cobj->{id} if exists $cobj->{id};

        my @classes;
        if (exists $cobj->{class}) {
            @classes = grep $_, split /\./, $cobj->{class};
            my $first = shift @classes;
            push @args, class => qr/(?:.*?\s+)?\Q$first\E(?:\s+.*?)?/
              if $first;
        }

        $tag = $tag->get(@args);

        if ($tag && @classes) {
            my $tagclass = $tag->attr('class');
            foreach (@classes) {
                next TAG
                  if $tagclass !~ /(?:.*?\s+)?\Q$_\E(?:.*?\s+)?/;
            }
        }
    }

    $tag;
}

sub import {
    my $caller = caller;
    no strict 'refs';
    *{"${caller}::get_tag"}       = \&get;
    *{"${caller}::get_tag_inner"} = \&inner;
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
    my $tag2 = get_tag $string, 'div', id    => 'foo';
    my $tag3 = get_tag $string, 'div', class => 'bar';
    my $tag4 = get_tag $string, id => 'foo';


=head1 DESCRIPTION

Not very relaible tool that allows to get tag content from XML-like documents.
Comment and CDATA tags are not respected.

=head1 FUNCTIONS

L<Util::YKO::GetTag> exports following functions:

=head2 get_tag

    my $tag = get_tag $html, $tag, %options;
    my $tag = get_tag $html, $tag, id => 'foo', class => 'bar';
    my $tag = get_tag $html, id => 'foo', class => 'bar';

    my ($tag, $start, $end) = get_tag $html, $tag, %options;

In scalar context returns tag content wrapped in Util::YKO::GetTag object.

In list context returns tag content,
start pos and end pos in original html string

If no tag name provided, returns first tag that matches attributes set.
As options accepts list of tag attributes.

If no tag name and options provided, returns first tag.

=head2 get_tag_inner

    my $tag = get_tag_inner $html, $tag, %options;
    my $tag = get_tag_inner $html, $tag, id => 'foo', class => 'bar';

    my ($tag, $start, $end) = get_tag_inner $html, $tag, %options;

In scalar context returns tag content wrapped in Util::YKO::GetTag object.

In list context returns tag inner content,
start pos and end pos in original html string

As options accepts list of tag attributes

=head1 METHODS

L<Util::YKO::GetTag> objects have following methods:

=head2 new

Create new GetTag instance. Accepts html string as a single parameter.

    my $tag = Util::YKO::GetTag->new("<div />");

=head2 child

Creates new GetTag instance from current.
Accepts two parameters: start pos and end pos.

    my $child = $tag->child(0, 100);

=head2 get

See get_tag function

    my $child = $tag->get($tag, %options);

=head2 inner

See get_tag_inner function

    my $child = $tag->inner($tag, %options);

=head2 reset

Search from beginning. The same as pos($string) = 0

=head2 attr

Get tag attribute

    my $class = $tag->attr('class')

=head1 LICENCE AND COPYRIGHT

Copyright (C) 2011, Yaroslav Korshak.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
