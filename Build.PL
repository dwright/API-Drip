use v5.14;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'API::Drip',
    license             => 'perl_5',
    dist_author         => q{Dan Wright <Dan@DWright.Org>},
    dist_version_from   => 'lib/API/Drip/Request.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => '0',
    },
    build_requires => {
        'Test::More' => '0',
    },
    requires => {
        #'ABC'              => '1.6',
        #'Foo::Bar::Module' => '5.0401',
    },
    add_to_cleanup     => [ 'API-Drip-*' ],
);

$builder->create_build_script();
