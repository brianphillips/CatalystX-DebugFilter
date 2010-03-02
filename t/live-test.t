#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

# setup library path
use FindBin qw($Bin);
use lib "$Bin/lib";

# make sure testapp works
use ok 'TestApp';
my $logger = MyLogger->new;
TestApp->log($logger);
TestApp->debug(1);

# a live test against TestApp, the test application
use Test::WWW::Mechanize::Catalyst 'TestApp';
my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->get_ok('http://localhost/?foo_param=secret', ['X-Secret' => 'Secret value'], 'get main page');
my $log = $logger->GET;
like $log, qr{X-Secret.*FILTERED}, 'X-Secret header is filtered';
like $log, qr{foo_param.*FILTERED}, 'foo_param is filtered';
like $log, qr{foo_param.*FILTERED}, 'foo_param is filtered';
like $log, qr{X-Res-Secret-2.*FILTERED}, 'X-Res-Secret-2 is filtered';
like $log, qr{terceS}, 'Secret reversed';
like $log, qr{NotASecret}, 'other response headers left untouched is filtered';

$logger->CLEAR;
$mech->{catalyst_debug} = 1;
my $error_screen = $mech->get('http://localhost/boom?foo_param=secret')->content;
my $expected_debug = "parameters       =&gt; { foo_param =&gt; &quot;[FILTERED]&quot; }";
like $error_screen, qr/\Q$expected_debug/, 'filtered on debug screen';

done_testing;

BEGIN {
	package MyLogger;
	use Moose;
	extends 'Catalyst::Log';
	my @log;
	sub _send_to_log {
		my $self = shift;
		push @log, @_;
		return;
	}
	sub GET {
		return wantarray ? @log : join "\n", @log;
	}
	sub CLEAR {
		@log = ();
	}
}
