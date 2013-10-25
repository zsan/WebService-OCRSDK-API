use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WebService::OCRSDK::API',
    license             => 'perl',
    dist_author         => q{Zakarias Santanu <zaksantanu@gmail.com>},
    dist_version_from   => 'lib/WebService/OCRSDK/API.pm',
    build_requires => {
    	'Test::More' => 0,
    	'Data::OpenStruct::Deep' => 0,
    	'LWP::UserAgent' => 0,
    	'Modern::Perl' => 0,
		'Moose' => 0,
		'MooseX::Privacy' => 0,
		'URI::Escape' => 0,		
		'XML::Simple' => 0,
    },
    add_to_cleanup      => [ 'WebService-OCRSDK-API-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
