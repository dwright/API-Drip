#!/usr/bin/env perl

=head1 NAME

drip_client.pl -- Command-line interface to connect to getdrip.com

=head1 SYNOPSIS

drip_client.pl [general options] [operation] [parameters]

=head1 OPTIONS

=head2 General Options

=over 4

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-v,-verbose>

Be verbose about something.  Specify it more than once to be even more verbose.

=item B<-conf>

Specify the location of a configuration file.   Otherwise, defaults to location
specified in the DRIP_CLIENT_CONF environment variable or ~/.drip.conf.   Data
in the configuration file must be encoded in YAML format.   See
L<API::Drip::Request/"CONFIGURATION"> for the specific data that may be stored.

Each configuration item may also be overriden by setting an environment
variable with the same name.

=back

=head2 Operations

=over

=item B<getsub>

Get a list of all subscribers.

=item B<addsub>

Add a subscriber.   At a minimum, must also specify -email, or -id.

Accepts: -email, -id, -new_email, -user_id, -time_zone, -lifetime_value, -ip_address

=item B<delsub>

Delete a subscriber.   Must specify -email, or -id.

=back

=head2 Additional Parameters

The parameters B<-email>, B<-id>, B<-new_email>, B<-user_id>, B<-time_zone>,
B<-lifetime_vaule>, and B<-ip_address> are documented at
L<https://www.getdrip.com/docs/rest-api> and may be used with the above
operations.

=head1 DESCRIPTION

B<drip_client.pl> is a command-line interface to the API::Drip library.   It's
a handy way to verify your connection to Drip is working as expected, and
possibly to do some light-weight manipulation of your data.

=cut

use v5.14;
use strict;
use lib '/usr/pair/perl/lib';
use Pair::Result ':all';

use Data::Printer;
use Getopt::Long;
use Pod::Usage;
use Readonly;

my %OPT = ( # Add defaults here.
);

GetOptions( \%OPT,
    'help|h|?',
    'man',
    'verbose|verb|v+',
    'conf=s',
    'addsub', 'getsub', 'delsub',
    'email=s', 'id=s', 'new_email=s', 'user_id=s', 'time_zone=s', 'lifetime_vaule=i', 'ip_address=s', 
) or pod2usage(2);
pod2usage(1) if $OPT{help};
pod2usage(-exitval => 0, -verbose => 2) if $OPT{man};
p %OPT if $OPT{verbose};

use API::Drip::Request;
my $client = API::Drip::Request->new( $OPT{conf} ? ( DRIP_CLIENT_CONF => $OPT{conf} ) : () );

eval {
    if ( $OPT{getsub} ) {  get_subscribers() and exit }
    if ( $OPT{addsub} ) {  add_subscribers( %OPT ) and exit }
    if ( $OPT{delsub} ) {  delete_subscribers( %OPT ) and exit }
};
if ( $@ ) {
    warn "Request failed:";
    p $@;
}

exit;


sub delete_subscribers {
    my %OPT = @_;
    my $id = $OPT{email} || $OPT{id};

    die "email or id required in delete subscriber" unless $id;

    my $result = $client->do_request( DELETE => "subscribers/$id" );
    p $result;

}

sub add_subscribers {
    my %OPT = @_;
    my $subscriber = _build_subscriber_hash( %OPT );
    die "email or id required in add subscriber" unless $subscriber->{email} or $subscriber->{id};

    my $result = $client->do_request( POST => 'subscribers', { subscribers => [ $subscriber ]});
    p $result;
}

sub _build_subscriber_hash {
    my %OPT = @_;
    my $subscriber = {};
    foreach my $key ( qw( email id new_email user_id time_zone lifetime_value ip_address ) ) {
        next unless defined $OPT{$key};
        $subscriber->{$key} = $OPT{$key};
    }
    return $subscriber;
}

sub get_subscribers {
    my $result = $client->do_request( GET => 'subscribers' );
    p $result;
}

