#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 2;

use_ok 'Util::YKO::Starter';

can_ok 'Util::YKO::Starter', 'ignores_guts';
