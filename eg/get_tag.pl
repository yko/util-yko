#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Util::YKO::GetTag

$/ = undef;
my $data = Util::YKO::GetTag->new(<DATA>);

print "Using html as example:\n$data\n";

my $body = $data->get('body');

print "- Get single element:\n";
my $content = $body->inner('h1');
print "H1 content: '$content'\n";

print "\n- Loop over elements:\n";
my $table = $body->get('table');
while (my $row = $table->get('tr')) {
    print "Cell content: '" . $row->inner('td') . "'\n";
}

print "\n- Get single element again:\n";
$content = $body->inner('h1');
print "H1 content: '$content'\n";

print "\n- Go back\n";
$body->reset;
$content = $body->inner('h1');
print "H1 content: '$content'\n";

__DATA__
<!-- example from w3c html5 spec-->
<html>
<body>

<h1>My First Heading</h1>

<table>
 <tr><td>Foo</td></tr>
 <tr><td>Bar</td></tr>
 <tr><td>Baz</td></tr>
</table>

<h1>My Second Heading</h1>
</body>
</html>
