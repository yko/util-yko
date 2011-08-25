use inc::Module::Install;

name     'util-yko';
all_from 'lib/Util/YKO/GetTag.pm';
author   q{Yaroslav Korshak <ykorshak@gmail.com>};
license  'perl';

build_requires 'Test::More';
requires 'Carp';
requires 'Scalar::Util';

auto_install;

WriteAll;
