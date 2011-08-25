#!/usr/bin/env perl
use strict;
use warnings;

BEGIN {
    use Test::More tests => 6;
    use_ok 'Util::YKO::GetTag';
}

my $html = Util::YKO::GetTag->new("foo <p class='foo'> bar </p> baz");
is $html, "foo <p class='foo'> bar </p> baz";

is $html->get_tag('p'), "<p class='foo'> bar </p>";
isa_ok $html, 'Util::YKO::GetTag';

$html->reset;

is $html->get_tag('p', class => 'foo'), "<p class='foo'> bar </p>";
isa_ok $html, 'Util::YKO::GetTag';
