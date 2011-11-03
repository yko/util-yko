#!/usr/bin/env perl
use strict;
use warnings;

BEGIN {
    use Test::More tests => 9;
    use_ok 'Util::YKO::GetTag';
}

my $html = "<p class='test'> bar </p> foo <p class='test'> baz </p>";
my $tag = get_tag $html, 'p.test';

isa_ok $tag => 'Util::YKO::GetTag';
is $tag => "<p class='test'> bar </p>", "css by class";

pos($html) = 0;
my @tags = get_tag $html, 'p.test';

is_deeply \@tags, ["<p class='test'> bar </p>", "<p class='test'> baz </p>"];

$html = "<p class='test test2'> bar </p> baz";
$tag = get_tag $html, 'p.test.test2';

is $tag => "<p class='test test2'> bar </p>", "css by multiple classes";
$html = "<p id='test'> bar </p> baz";

is get_tag($html, 'p#test') => "<p id='test'> bar </p>";

$html = "<p class='baz'> fake </p> <p id='test'> bar <p class='baz'> baz </p> </p>";

is get_tag($html, 'p#test .baz') => "<p class='baz'> baz </p>";

pos($html) = 0;
is get_tag($html, 'fake, p#test .baz') => "<p class='baz'> baz </p>";

$html = "<p class='123 baz 456 bar 789'> inner </p>";
is get_tag($html, 'p.baz.bar') =>
  "<p class='123 baz 456 bar 789'> inner </p>";
