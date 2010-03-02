package TestApp;
use Moose;
use namespace::autoclean;


use Catalyst;
with 'CatalystX::DebugFilter';
__PACKAGE__->mk_classdata('debug');
__PACKAGE__->config(
	'CatalystX::DebugFilter' => {
		Request => { params => 'foo_param', headers => 'X-Secret' },
		Response => { headers => [ qr{X-Res-Secret-2}i, sub { my ( $k, $v ) = @_; return $k eq 'X-Res-Secret-1' ? reverse($v) : undef  } ] }
	}
);

extends 'Catalyst';

__PACKAGE__->setup;

1;
