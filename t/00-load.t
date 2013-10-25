#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'WebService::OCRSDK::API' ) || print "Bail out!";
}

diag( "Testing WebService::OCRSDK::API $WebService::OCRSDK::API::VERSION, Perl $], $^X" );
