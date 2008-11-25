use inc::Module::Install;
name 'WWW-YahooJapan-Speech';
all_from 'lib/WWW/YahooJapan/Speech.pm';

test_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
