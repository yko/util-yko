#!/usr/bin/env perl
use strict;
use warnings;

BEGIN {
    use Test::More tests => 12;
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

$html = "foo<div> <p class='bar_class' /> bar </p> baz</div>";
$tag = get_tag $html, 'p', class => 'bar_class';

is $tag, "<p class='bar_class' />", "self-closing tag";


$html = "<div> foo <div class='bar_class'/> baz </div>";
$tag = get_tag $html, 'div', class => 'bar_class';

is $tag, "<div class='bar_class'/>", "self-closing tag with tag";

pos($html) = 0; # Reset \G position
$tag = get_tag $html, 'div', class => qr/bar_\w+/;

is $tag, "<div class='bar_class'/>", "match parameter value via regexp";

$html = "<divfake> foo <div class='bar_class'/> baz </divfake>";
$tag = get_tag $html, 'div';
is $tag, "<div class='bar_class'/>", 'choose right tag';
