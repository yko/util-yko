#!/usr/bin/env perl
use strict;
use warnings;

BEGIN {
    use Test::More tests => 13;
    use_ok 'Util::YKO::GetTag';
}

my $html = "<p class='test'> bar </p> baz";
my $tag = get_tag $html, 'p';

can_ok $tag => 'attr';

is $tag->attr('class') => 'test', 'quoted attr';

$html = '<p class="test"> bar </p> baz';
$tag = get_tag $html, 'p';
is $tag->attr('class') => 'test', 'doublequoted attr';

$html = '<p> bar </p> baz';
$tag = get_tag $html, 'p';
is $tag->attr('class') => undef, 'unexisting attr';

$html = '<p class> bar </p> baz';
$tag = get_tag $html, 'p';
is $tag->attr('class') => '', 'empty attr';

$html = '<p class=> bar </p> baz';
$tag = get_tag $html, 'p';
is $tag->attr('class') => '', 'empty attr';

$html = '<p class= style="color:red"> bar </p> baz';
$tag = get_tag $html, 'p';
is $tag->attr('class') => '', 'empty attr';

$html = '<p class class="foo"> bar </p> baz';
$tag = get_tag $html, 'p';
is $tag->attr('class') => '', 'empty attr goes first with multiple attr';

$html = '<p class=test> bar </p> baz';
$tag = get_tag $html, 'p';
is $tag->attr('class') => 'test', 'unquoted attr';

$html = '<p class=test foo> bar </p> baz';
$tag = get_tag $html, 'p';
is $tag->attr('class') => 'test', 'unquoted attr';

$html = '<p class="test" class="bar"> bar </p> baz';
$tag = get_tag $html, 'p';
is $tag->attr('class') => 'test', 'multiple attr';

$html = '<p class="test&gt;"> bar </p> baz';
$tag = get_tag $html, 'p';
is $tag->attr('class') => 'test>', 'escaped text in attr';
