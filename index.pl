#!/usr/bin/env perl
use warnings;
use strict;
use utf8;
use Web::Simple 'HowLong';
use Text::Xslate ();
use Encode ();
use DateTime;

{
    package HowLong;
    DateTime->DefaultLocale('pt_BR');
    my $tx = Text::Xslate->new( path => [ '.' ] );

    sub get_deltas {
        my $today = DateTime->now->set_time_zone('America/Sao_Paulo')->truncate(to => 'day');

        my $big_day = DateTime->new(
            year  => 2013,
            month => 9,
            day   => 25,
            time_zone => 'America/Sao_Paulo',
        );

        my ( $md_months, $md_days ) = $big_day->delta_md( $today )->in_units( 'months', 'days' );
        my ( $total_days ) = $big_day->delta_days( $today )->in_units( 'days' );

        return {
            md_months  => $md_months,
            md_days    => $md_days,
            total_days => $total_days,
        };
    }

    sub dispatch_request {
        sub (GET) {
            [
                200,
                [ 'Content-type', 'text/html; charset=utf-8' ],
                [ Encode::encode( 'utf-8', $tx->render('index.tx', get_deltas()) ) ]
            ];
        },
        sub () {
            [ 405, [ 'Content-type', 'text/plain' ], ['Method not allowed'] ];
        }
    }
}

HowLong->run_if_script;
