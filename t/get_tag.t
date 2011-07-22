#!/usr/bin/env perl
use strict;
use warnings;

BEGIN {
    use Test::More tests => 8;
    use_ok 'Util::YKO::GetTag';
}

my $html = "foo <p> bar </p> baz";
my $tag = get_tag $html, 'p';

is $tag, '<p> bar </p>';

$html = "foo <p id='bar_id'> bar </p> baz";
$tag = get_tag $html, 'p', id => 'bar_id';

is $tag, "<p id='bar_id'> bar </p>";

$html = "foo <p id='bar_id' class='bar_class'> bar </p> baz";
$tag = get_tag $html, 'p', id => 'bar_id', class => 'bar_class';

is $tag, "<p id='bar_id' class='bar_class'> bar </p>";

$html = "foo <p id='bar_id' class='bar_class'> bar </p> baz";
$tag = get_tag $html, 'p',class => 'bar_class';

is $tag, "<p id='bar_id' class='bar_class'> bar </p>";

$html = "foo<div> <p id='bar_id'> bar </p> baz</div>";
$tag = get_tag $html, 'p', id => 'bar_id';

is $tag, "<p id='bar_id'> bar </p>";

$html = "foo<div> <p class='bar_class'> <p class='bar_class'>bar</p> </p> baz</div>";
$tag = get_tag $html, 'p', class => 'bar_class';

is $tag, "<p class='bar_class'> <p class='bar_class'>bar</p> </p>";

$html = "foo<div> <p class='bar_class'> <span>bar </p> baz</div>";
$tag = get_tag $html, 'p', class => 'bar_class';

is $tag, "<p class='bar_class'> <span>bar </p>";
