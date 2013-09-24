#!/usr/bin/env perl
use warnings;
use strict;
use utf8;
use Web::Simple 'HowLong';
use Text::Xslate ();
use Encode ();
use DateTime;

my $slurped_data;

{
    local $/;
    $slurped_data = <DATA>;
}

{
    package HowLong;
    DateTime->DefaultLocale('pt_BR');
    my $tx = Text::Xslate->new( path => [ { 'main.tx' => $slurped_data } ] );

    sub get_deltas {
        my $today = DateTime->now->set_time_zone('America/Sao_Paulo')->truncate(to => 'day');

        my $big_day = DateTime->new(
            year  => 2014,
            month => 2,
            day   => 2,
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
                [ Encode::encode( 'utf-8', $tx->render('main.tx', get_deltas()) ) ]
            ];
        },
        sub () {
            [ 405, [ 'Content-type', 'text/plain' ], ['Method not allowed'] ];
        }
    }
}

HowLong->run_if_script;

__DATA__
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <title>Quanto falta</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta charset="utf-8">
  <link href="//netdna.bootstrapcdn.com/bootswatch/3.0.0/cerulean/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container">
  <div class="row">
    <div class="col-lg-12">
      <div class="page-header">
        <h1>Quanto falta?</h1>
      </div>
      <p class="lead"><strong><: $md_months :></strong> meses e <strong><: $md_days :></strong> dias, ou seja, <strong><: $total_days :></strong> dias para o casamento.</p>
    </div>
  </div>
</div>
</body>
</html>
