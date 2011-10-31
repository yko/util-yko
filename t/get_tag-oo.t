#!/usr/bin/env perl
use strict;
use warnings;

BEGIN {
    use Test::More tests => 12;
    use_ok 'Util::YKO::GetTag';
}

my $html = Util::YKO::GetTag->new("foo <p class='foo'> bar </p> baz");
is $html, "foo <p class='foo'> bar </p> baz", 'stringify';

is $html->get('p'), "<p class='foo'> bar </p>", 'get tag';
isa_ok $html, 'Util::YKO::GetTag';
$html->reset;

is $html->get('p', class => 'foo'), "<p class='foo'> bar </p>", 'get tag by class';
isa_ok $html, 'Util::YKO::GetTag';
$html->reset;

my $inner = $html->inner('p');
is $inner, " bar ", 'inner';
isa_ok $html, 'Util::YKO::GetTag';

$html->reset;
is $html->get(class => 'foo'), "<p class='foo'> bar </p>", 'get tag by attrs';
isa_ok $html, 'Util::YKO::GetTag';

$html->reset;
$inner = $html->inner(class => 'foo');
is $inner, " bar ", 'inner by attrs';
isa_ok $html, 'Util::YKO::GetTag';
